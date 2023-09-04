defmodule IndexOutOfBoundsError do
  defexception [:index, :bound]

  @impl true
  def exception({index, bound}) do
    %IndexOutOfBoundsError{index: index, bound: bound}
  end

  @impl true
  def message(error) do
    "index #{error.index} is out of bounds [0-#{error.bound})"
  end
end

defmodule Homework do
  @spec get_from_list!([any()], integer()) :: any()
  def get_from_list!(list, index) do
    if index < 0 do
      raise IndexOutOfBoundsError, {index, length(list)}
    end

    case Enum.fetch(list, index) do
      {:ok, element} ->
        element

      :error ->
        raise IndexOutOfBoundsError, {index, length(list)}
    end
  end

  @spec get_from_list([any()], integer()) :: {:ok, any()} | {:error, String.t()}
  def get_from_list(list, index) do
    try do
      element = get_from_list!(list, index)
      {:ok, element}
    rescue
      error -> {:error, Exception.message(error)}
    end
  end

  @spec get_many_from_list!([any()], [integer()]) :: [any()]
  def get_many_from_list!(list, indices) do
    Enum.map(indices, fn index -> get_from_list!(list, index) end)
  end

  @spec get_many_from_list([any()], [integer()]) :: {:ok, [any()]} | {:error, String.t()}
  def get_many_from_list(list, indices) do
    indices
    |> Enum.map(fn index -> get_from_list(list, index) end)
    |> Enum.reduce(
      {:ok, []},
      fn
        _, {:error, _} = acc -> acc
        {:ok, value}, {:ok, acc} -> {:ok, acc ++ [value]}
        {:error, _} = e, _ -> e
      end
    )
  end
end
