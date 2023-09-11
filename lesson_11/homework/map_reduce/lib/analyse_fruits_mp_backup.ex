defmodule AnalyseFruitsMP do
  @moduledoc """
  MapReduce solution
  """

  @type mapper_id :: integer
  @type mapper :: {:mapper, mapper_id, String.t()}
  @type reducer_id :: {integer, integer}
  @type children :: [mapper] | [reducer]
  @type reducer :: {:reducer, reducer_id, children}
  @type result :: %{String.t() => integer}

  @spec test(integer) :: {:ok, result} | {:error, term}
  def test(processes_per_level \\ 2) do
    files = [
      "./data/data_1.csv",
      "./data/data_2.csv",
      "./data/data_3.csv"
      # "./data/data_5.csv"
    ]

    start(files, processes_per_level)
  end

  @spec start([String.t()], integer) :: {:ok, result} | {:error, term}
  def start(files, processes_per_level \\ 4) do
    # TODO add your implementation
    process_tree = build_processes_tree(files, processes_per_level)
    AnalyseFruitsMP.Coordinator.start(process_tree)
  end

  @spec build_processes_tree([String.t()], integer) :: reducer
  def build_processes_tree(files, processes_per_level) do
    # TODO add your implementation
    Enum.with_index(files, fn file, i -> {:mapper, i + 1, file} end)
    |> tree(processes_per_level)
    |> traversal()
  end

  def tree(files, per_level) do
    cond do
      length(files) <= per_level ->
        files

      true ->
        chunks = Enum.chunk_every(files, per_level)
        tree(chunks, per_level)
    end
  end

  def get_range(tree) do
    flattened = List.flatten(tree)
    {:mapper, first, _} = List.first(flattened)
    {:mapper, last, _} = List.last(flattened)
    {first, last}
  end

  def traversal(tree) do
    case tree do
      list when is_list(list) ->
        {first, last} = get_range(list)
        {:reducer, {first, last}, Enum.map(list, &traversal/1)}

      {:mapper, num, path} ->
        {:mapper, num, path}
    end
  end

  defmodule Coordinator do
    # TODO add your implementation
    alias AnalyseFruitsMP.Mapper
    alias AnalyseFruitsMP.Reducer

    def start(tree) do
      start(self(), tree)

      receive do
        {:result, _, result} -> {:ok, result}
        msg -> {:error, :unknown_msg, msg}
      after
        5000 -> {:error, :timeout}
      end
    end

    defp start(parent, {:reducer, id, childs}) do
      child_ids = Enum.map(childs, fn {_, id, _} -> id end)
      pid = spawn(Reducer, :start, [parent, id, child_ids])
      for child <- childs, do: start(pid, child)
    end

    defp start(parent, {:mapper, id, file}) do
      spawn(Mapper, :start, [parent, id, file])
    end
  end

  defmodule Mapper do
    # TODO add your implementation
    def start(parent, id, file) do
      IO.puts("start mapper #{id} with file #{file}")
      result = process(file)
      send(parent, {:result, id, result})
    end

    defp process(file) do
      file
      |> File.stream!()
      |> CSV.decode()
      |> Enum.reduce(%{}, fn {:ok, [_, fruit, count, _]}, acc ->
        Map.put(acc, fruit, String.to_integer(count))
      end)
    end
  end

  defmodule Reducer do
    # TODO add your implementation
    def start(parent, range, child_ids) do
      IO.puts("start reducer #{inspect(range)} with childs #{inspect(child_ids)}")
      result = wait_for_results(range, child_ids, %{})
      send(parent, {:result, range, result})
    end

    defp wait_for_results(_range, [], acc) do
      acc
    end

    defp wait_for_results(range, child_ids, acc) do
      receive do
        {:result, child_id, result} ->
          IO.puts("reducer #{inspect(range)} got result #{inspect(result)} from #{child_id}")

          wait_for_results(
            range,
            List.delete(child_ids, child_id),
            Map.merge(acc, result, fn _k, v1, v2 -> v1 + v2 end)
          )
      after
        5000 ->
          IO.puts("reducer #{inspect(range)} hasn't got all results")
      end
    end
  end
end
