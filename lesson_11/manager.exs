defmodule Manager do
  defmodule Session do
    @type t :: %__MODULE__{
            username: String.t(),
            num_shard: integer(),
            num_node: integer()
          }
    defstruct [:username, :num_shard, :num_node]
  end

  defmodule SessionManager do
    @spec start() :: pid()
    def start() do
      state = []

      {:ok, pid} = Agent.start(fn -> state end)
      pid
    end

    def stop(agent_pid) do
      Agent.stop(agent_pid)
    end

    @spec add_session(pid(), String.t()) :: {:ok, Session.t()}
    def add_session(agent_pid, username) do
      {:ok, {num_shard, num_node}} = Manager.ShardManager.settle(username)
      session = %Session{username: username, num_shard: num_shard, num_node: num_node}
      Agent.update(agent_pid, fn state -> [session | state] end)
      {:ok, session}
    end

    @spec get_sessions(pid()) :: [Session.t()]
    def get_sessions(agent_pid) do
      Agent.get(agent_pid, fn state -> state end)
    end

    @spec get_session_by_name(pid(), String.t()) :: {:ok, Session.t()} | nil
    def get_session_by_name(agent_pid, username) do
      Agent.get(agent_pid, fn state -> find_session(state, username) end)
    end

    defp find_session(sessions, name) do
      Enum.find(sessions, fn session -> session.username == name end)
    end
  end

  defmodule ShardManager do
    @spec start() :: pid()
    def start() do
      state = [
        {1, 7, "node-1"},
        {8, 15, "node-2"},
        {16, 23, "node-3"},
        {24, 31, "node-4"}
      ]

      Agent.start(fn -> state end, name: :shards)
      {:ok, state}
    end

    @spec settle(String.t()) :: {Range.t(1..31), String.t()}
    def settle(username) do
      num_shard = :erlang.phash2(username, 31)
      {:ok, node_name} = find_node(num_shard)
      {:ok, {num_shard, node_name}}
    end

    @spec find_node(integer()) :: String.t()
    def find_node(num_shard) do
      Agent.get(:shards, fn state -> find_node(state, num_shard) end)
    end

    defp find_node(state, num_shard) do
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
end
