defmodule QuadraticEquation do
  @moduledoc """
  https://en.wikipedia.org/wiki/Quadratic_equation
  """

  @doc """
  function accepts 3 integer arguments and returns:
  {:roots, root_1, root_2} or {:root, root_1} or :no_root

  ## Examples
  iex> QuadraticEquation.solve(1, -2, -3)
  {:roots, 3.0, -1.0}
  iex> QuadraticEquation.solve(3, 5, 10)
  :no_roots
  """
  def solve(a, b, c) do
    case discriminant(a, b, c) do
      d when d < 0 -> :no_roots
      0 -> {:root, -b / (2 * a)}
      d -> 
        root1 = (-b + :math.sqrt(d)) / (2 * a)
        root2 = (-b - :math.sqrt(d)) / (2 * a)
        {:roots, root1, root2}
    end
  end

  defp discriminant(a, b, c) do
    b ** 2 - 4 * a * c
  end

end
