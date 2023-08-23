defmodule IntExample do
  def gcd(a, b) when a < 0 or b < 0 do
    gcd(abs(a), abs(b))
  end

  def gcd(a, 0), do: a

  def gcd(a, b) do
    case rem(a, b) do
      0 -> b
      c -> gcd(b, c)
    end
  end
end

IntExample.gcd(5, 55) |> IO.puts
IntExample.gcd(-5, 55) |> IO.puts
IntExample.gcd(5, -55) |> IO.puts
IntExample.gcd(0, 5) |> IO.puts
IntExample.gcd(5, 0) |> IO.puts
