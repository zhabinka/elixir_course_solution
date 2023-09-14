defmodule LRU2 do
  use GenServer
  require Logger

  def test() do
    options = %{
      timeout: 100 * 1000
    }

    IO.puts("start test")
    start_link(options)
  end

  # Public API
  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def introspect() do
    GenServer.call(__MODULE__, :introspect)
  end

  def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  # GenServer callbacks
  @impl true
  def init(options) do
    timeout = Map.get(options, :timeout, 2 * 50 * 1000)
    num_tables = Map.get(options, :num_tables, 5)
    rotation_time = div(timeout, num_tables)

    tables = create_tables(num_tables)

    state = %{
      tables: tables,
      timeout: timeout,
      rotation_time: rotation_time
    }

    IO.puts("LRU2 started with state #{inspect(state)}")
    Process.send_after(self(), :rotate, rotation_time)
    {:ok, state}
  end

  @impl true
  def handle_call(:introspect, _from, state) do
    %{tables: tables} = state
    Enum.each(tables, &show_table/1)
    {:reply, :ok, state}
  end

  def handle_call({:put, key, value}, _from, state) do
    %{tables: tables} = state
    [first_table | _] = tables
    :ets.insert(first_table, {key, value})
    {:reply, {:ok, {key, value}}, state}
  end

  def handle_call({:get, key}, _from, %{tables: tables} = state) do
    reply =
      case lookup_tables(tables, key) do
        {:ok, value} ->
          [first_table | _] = tables
          :ets.insert(first_table, {key, value})

          {:ok, value}

        {:error, :not_found} ->
          {:error, :not_found}
      end

    {:reply, reply, state}
  end

  def handle_call({:delete, key}, _from, %{tables: tables} = state) do
    Enum.each(tables, fn table -> :ets.delete(table, key) end)
    {:reply, :ok, state}
  end

  # Catch all
  def handle_call(msg, _from, state) do
    Logger.info("Invalid handle_call #{inspect(msg)}")
    {:reply, {:error, :invalid_call}, state}
  end

  @impl true
  def handle_info(:rotate, %{tables: tables, rotation_time: rotation_time} = state) do
    IO.puts("Rotate tables")
    new_tables = rotate_tables(tables)
    Enum.each(new_tables, &show_table/1)
    new_state = %{state | tables: new_tables}
    Process.send_after(self(), :rotate, rotation_time)
    {:noreply, new_state}
  end

  def handle_info(msg, state) do
    Logger.warning("Invalid handle_info #{inspect(msg)}")
    {:noreply, state}
  end

  def create_tables(num_tables) do
    1..num_tables
    |> Enum.map(fn id ->
      table_name = "cache_#{id}" |> String.to_atom()
      :ets.new(table_name, [:private])
    end)
  end

  def show_table(tid) do
    table_name = :ets.info(tid, :name)
    data = :ets.tab2list(tid)
    IO.puts("Table #{table_name} with data #{inspect(data)}")
  end

  def rotate_tables(tables) do
    [last_table | rest] = Enum.reverse(tables)
    table_name = :ets.info(last_table, :name)
    :ets.delete(last_table)
    new_table = :ets.new(table_name, [:private])
    [new_table | Enum.reverse(rest)]
  end

  defp lookup_tables(tables, key) do
    Enum.reduce(tables, {:error, :not_found}, fn
      _table, {:ok, value} ->
        {:ok, value}

      table, {:error, :not_found} ->
        table_name = :ets.info(table, :name)

        case :ets.lookup(table, key) do
          [] ->
            {:error, :not_found}

          [{_key, val}] ->
            Logger.info(
              "found key #{inspect(key)} with value #{inspect(val)} in #{inspect(table_name)}"
            )

            {:ok, val}
        end
    end)
  end
end
