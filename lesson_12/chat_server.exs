defmodule ChatServer do
  defmodule ClientSession do
    use GenServer, restart: :transient
    # Client API

    def start_link(client_id) do
      GenServer.start_link(__MODULE__, client_id)
    end

    def stop(pid) do
      GenServer.call(pid, :stop)
    end

    @impl true
    def init(client_id) do
      state = %{
        client_id: client_id
      }

      IO.puts("ClientSession #{inspect(self())} start with state #{inspect(state)}")

      {:ok, state}
    end

    # Server callbacks

    @impl true
    def handle_call(:stop, _from, state) do
      %{client_id: client_id} = state
      IO.puts("ClientSession #{inspect(self())} stop, client_id: #{inspect(client_id)}")
      {:stop, :normal, state}
    end

    # TODO: Catch all
  end

  defmodule SessionManager do
    use DynamicSupervisor

    @session_manager :session_manager

    # Module API
    def start() do
      SessionManager.start_link(:no_args)
    end

    def start_link(_) do
      DynamicSupervisor.start_link(__MODULE__, :no_args, name: @session_manager)
    end

    def start_session(client_id) do
      child_spec = {ClientSession, client_id}
      DynamicSupervisor.start_child(@session_manager, child_spec)
    end

    def stop_session(pid) do
      GenServer.stop(pid)
    end

    # Callbacks

    @impl true
    def init(:no_args) do
      IO.puts("SessionManager #{inspect(self())} start")
      DynamicSupervisor.init(strategy: :one_for_one)
    end
  end
end
