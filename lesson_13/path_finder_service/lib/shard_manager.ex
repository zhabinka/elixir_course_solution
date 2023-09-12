defmodule ShardManager do
  use Agent

  @spec start_link(list()) :: {:ok, pid()}
  def start_link(state) do
    Agent.start_link(fn -> state end, name: :shards)
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
