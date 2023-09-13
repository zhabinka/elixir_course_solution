defmodule Ets do
  def data_as_tuples() do
    [
      {:a, 1},
      {:b, 2},
      {:c, 3}
    ]

    users = [
      {:user, 1, "Bob", 42},
      {:user, 2, "Bill", 48},
      {:user, 3, "Helen", 22},
      {:user, 4, "John", 31}
    ]
  end

  def create_table() do
    tid = :ets.new(:table, [:named_table, keypos: 2])
  end
end
