defmodule TicTacToe do

  @type cell :: :x | :o | :f
  @type row :: {cell, cell, cell}
  @type game_state :: {row, row, row}
  @type game_result :: {:win, :x} | {:win, :o} | :no_win

  @spec valid_game?(game_state) :: boolean
  def valid_game?(state) do
    case state do
      {{a, b, c}, {d, e, f}, {g, h, i}} ->
        [a, b, c, d, e, f, g, h, i] |> Enum.map(&valid?/1) |> Enum.all?
      _ -> false
    end
  end

  defp valid?(value) do
    value in [:x, :o, :f]
  end

  @spec check_who_win(game_state) :: game_result
  def check_who_win(state) do
    case state do
      {{a, a, a}, {_, _, _}, {_, _, _}} when a != :f -> {:win, a}
      {{_, _, _}, {a, a, a}, {_, _, _}} when a != :f -> {:win, a}
      {{_, _, _}, {_, _, _}, {a, a, a}} when a != :f -> {:win, a}
      {{a, _, _}, {a, _, _}, {a, _, _}} when a != :f -> {:win, a}
      {{_, a, _}, {_, a, _}, {_, a, _}} when a != :f -> {:win, a}
      {{_, _, a}, {_, _, a}, {_, _, a}} when a != :f -> {:win, a}
      {{a, _, _}, {_, a, _}, {_, _, a}} when a != :f -> {:win, a}
      {{_, _, a}, {_, a, _}, {a, _, _}} when a != :f -> {:win, a}
      _ -> :no_win
    end
  end

end
