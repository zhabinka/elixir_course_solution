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
    case Enum.at(list, index) do
      _ when index < 0 -> raise IndexOutOfBoundsError, {index, length(list)}
      nil -> raise IndexOutOfBoundsError, {index, length(list)}
      element -> element
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

  @spec get_many_from_list!([any()], [integer()]) :: {:ok, [any()]} | {:error, String.t()}
  def get_many_from_list(list, indices) do
    try do
      resulting_list = get_many_from_list!(list, indices)
      {:ok, resulting_list}
    rescue
      error -> {:error, Exception.message(error)}
    end
  end
end
