defmodule Sup do
  def start() do
    child_spec = [
      {Sup.ShardManagerSup, :no_args},
      {Sup.MyServerSup, :no_args}
      # {Sup.MyServer, {:my_server, 42}}
      # {Sup.ShardManager, shard_manager_state}
    ]

    Supervisor.start_link(child_spec, strategy: :one_for_all)
  end

  defmodule ShardManagerSup do
    use Supervisor

    def start_link(_) do
      IO.puts("ShardManagerSup #{inspect(self())} start")
      Supervisor.start_link(__MODULE__, :no_args)
    end

    def init(:no_args) do
      shard_manager_state_1 = [
        {1, 7, "node-1"},
        {8, 15, "node-2"},
        {16, 23, "node-3"},
        {24, 31, "node-4"}
      ]

      shard_manager_state_2 = [
        {1, 100, "node-A"},
        {101, 200, "node-B"}
      ]

      child_spec = [
        %{
          id: :shard_manager_1,
          start: {Sup.ShardManager, :start_link, [:sm1, shard_manager_state_1]}
        },
        %{
          id: :shard_manager_2,
          start: {Sup.ShardManager, :start_link, [:sm2, shard_manager_state_2]}
        }
      ]

      Supervisor.init(child_spec, strategy: :one_for_one)
    end
  end

  defmodule MyServerSup do
    use Supervisor

    def start_link(_) do
      IO.puts("MyServerSup #{inspect(self())} start")
      Supervisor.start_link(__MODULE__, :no_args)
    end

    def init(:no_args) do
      child_spec = [
        %{
          id: :my_server_1,
          start: {Sup.MyServer, :start_link, [:s1, 1]}
        },
        %{
          id: :my_server_2,
          start: {Sup.MyServer, :start_link, [:s2, 1001]}
        }
      ]

      Supervisor.init(child_spec, strategy: :one_for_one)
    end
  end

  defmodule ShardManager do
    use Agent, restart: :permanent

    @spec start_link(String.t(), list()) :: {:ok, pid()}
    def start_link(name, state) do
      {:ok, pid} = Agent.start(fn -> state end, name: name)
      IO.puts("Start ShardManager #{name} #{inspect(pid)} with state #{inspect(state)}")
      {:ok, pid}
    end

    @spec find_node(String.t(), integer()) :: String.t()
    def find_node(name, num_shard) do
      Agent.get(name, fn state -> _find_node(state, num_shard) end)
    end

    defp _find_node(state, num_shard) do
      Enum.reduce(state, {:error, :not_found}, fn
        _, {:ok, res} ->
          {:ok, res}

        {min_shard, max_shard, node_name}, acc ->
          if num_shard in min_shard..max_shard do
            {:ok, node_name}
          else
            acc
          end
      end)
    end
  end

  defmodule MyServer do
    use GenServer

    # Client API
    def start_link(name, state) do
      GenServer.start(__MODULE__, state, name: name)
    end

    def call_a(name) do
      GenServer.call(name, :call_a)
    end

    def call_b(name) do
      GenServer.call(name, :call_b)
    end

    # Server callbacks

    def init(state) do
      IO.puts("MyServer #{inspect(self())} init with state #{inspect(state)}")
      {:ok, state}
    end

    def handle_call(:call_a, _from, state) do
      reply = state + 1
      {:reply, reply, state}
    end

    def handle_call(:call_b, _from, state) do
      reply = state + 100
      {:reply, reply, state}
    end
  end
end
