defmodule LRU do
  use GenServer
  require Logger

  # Client API
  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def put(key, value, timeout \\ nil) do
    GenServer.call(__MODULE__, {:put, key, value, timeout})
  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [] ->
        {:error, :not_found}

      [{^key, value, created_at, timeout}] ->
        now = :os.system_time(:millisecond)
        valid = created_at + timeout > now

        if valid do
          GenServer.cast(__MODULE__, {:update, key})
          {:ok, value}
        else
          delete(key)
          {:error, :timeout}
        end
    end
  end

  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  # Server callbacks
  @impl true
  def init(options) do
    tid = :ets.new(__MODULE__, [:named_table])
    Logger.info("ETS table #{inspect(tid)} created")

    state = %{
      default_timeout: Map.get(options, :default_timeout, 2 * 60 * 1000)
    }

    Logger.info("#{__MODULE__} start with state #{inspect(state)}")
    {:ok, state}
  end

  @impl true
  def handle_call({:put, key, value, key_timeout}, _from, state) do
    timeout =
      cond do
        key_timeout == nil -> state.default_timeout
        true -> key_timeout
      end

    now = :os.system_time(:millisecond)
    :ets.insert(__MODULE__, {key, value, now, timeout})
    Logger.info("Add #{inspect(key)} with value #{inspect(value)}, timeout #{inspect(timeout)}")
    {:reply, :ok, state}
  end

  def handle_call({:delete, key}, _from, state) do
    :ets.delete(__MODULE__, key)
    {:reply, :ok, state}
  end

  # Catch all
  def handle_call(msg, _from, state) do
    Logger.info("Unknow call #{inspect(msg)}")
    {:reply, {:error, :invalid_call}, state}
  end

  @impl true
  def handle_cast({:update, key}, state) do
    case :ets.lookup(__MODULE__, key) do
      [] ->
        {:ok}

      [{^key, value, _, timeout}] ->
        now = :os.system_time(:millisecond)
        :ets.insert(__MODULE__, {key, value, now, timeout})
    end

    {:noreply, state}
  end

  # Catch all
  def handle_cast(msg, state) do
    Logger.info("Unknow cast #{inspect(msg)}")
    {:noreply, state}
  end
end
