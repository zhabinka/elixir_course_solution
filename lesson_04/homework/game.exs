defmodule Game do

  def join_game(user) do
    {:user, _, age, role} = user
    cond do
      role in [:admin, :moderator] -> :ok 
      age >= 18 -> :ok
      true -> :error
    end
  end

  def move_allowed?(current_color, figure) do
    # case figure do
    #   {:pawn, ^current_color} -> true
    #   {:rock, ^current_color} -> true
    #   {_, _} -> false
    # end

    {type, color} = figure
    type in [:pawn, :rock] and color == current_color
  end

  def single_win?(a_win, b_win) do
    xor(a_win, b_win) 
  end

  defp xor(x, x), do: false
  defp xor(_x, _y), do: true

  def double_win?(a_win, b_win, c_win) do
    case {a_win, b_win, c_win} do
      {true, true, false} -> :ab
      {true, false, true} -> :ac
      {false, true, true} -> :bc
      {_, _, _} -> false
    end
  end

end
