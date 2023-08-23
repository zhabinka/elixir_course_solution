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

ExUnit.start()

defmodule IntExample_Test do
  use ExUnit.Case
  import IntExample

  test "gcd" do
    assert gcd(12, 9) == 3
    assert gcd(60, 48) == 12
  end

  test "gcd with negative numbers" do
    assert gcd(24, 18) == 6
    assert gcd(-24, 18) == 6
    assert gcd(24, -18) == 6
    assert gcd(-24, -18) == 6
  end

  test "gcd with zero" do
    assert gcd(12, 0) == 12
    assert gcd(0, 11) == 11
    assert gcd(0, 0) == 0
  end
end
