defmodule AnalyseFruitsSP do
  @moduledoc """
  Single process solution
  """

  @type result :: %{String.t() => integer}

  @spec start() :: result
  def start() do
    start([
      "./data/data_1.csv",
      "./data/data_2.csv",
      "./data/data_3.csv"
    ])
  end

  @spec start([String.t()]) :: result
  def start(files) do
    # TODO add your implementation
    files
    |> Enum.map(fn path ->
      path
      |> File.stream!()
      |> CSV.decode()
      |> Enum.reduce(%{}, fn {:ok, [_, fruit, count, _]}, acc ->
        Map.put(acc, fruit, String.to_integer(count))
      end)
    end)
    |> Enum.reduce(%{}, fn item, acc -> Map.merge(acc, item, fn _k, v1, v2 -> v1 + v2 end) end)
  end
end
