defmodule IntExample do
  def gcd(a, b) do
    case rem(a, b) do
      0 -> b
      c -> gcd(b, c)
    end
  end
end

IntExample.gcd(5, 55) |> IO.puts
