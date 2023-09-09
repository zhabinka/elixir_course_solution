defmodule GS do
  # Client API

  def start() do
    state = %{}
    pid = spawn(__MODULE__, :loop, [state])
    IO.puts("Server #{inspect(pid)} start from #{inspect(self())}")
    pid
  end

  def stop(pid) do
    send(pid, :stop)
  end

  def add(pid, k, v) do
    call(pid, {:add, k, v})
  end

  def remove(pid, k) do
    call(pid, {:remove, k})
  end

  def exist_key?(pid, k) do
    call(pid, {:exist_key?, k})
  end

  # Client generic call

  def call(pid, msg) do
    request_id = make_ref()
    send(pid, {msg, self(), request_id})

    receive do
      {:result, ^request_id, result} -> result
    after
      5000 -> {:no_reply, :timeout}
    end
  end

  # Generic inner loop

  def loop(state) do
    server_name = "Server #{inspect(self())}"
    IO.puts("#{server_name} enters loop with state #{inspect(state)}")

    receive do
      {msg, client_pid, ref} ->
        {result, new_state} = handlers_call(msg, state)
        send(client_pid, {:result, ref, result})
        __MODULE__.loop(new_state)

      :stop ->
        IO.puts("#{server_name} stop")

      msg ->
        IO.puts("#{server_name} got message #{inspect(msg)}")
        __MODULE__.loop(state)
    end
  end

  # Custom server handlers
  def handlers_call({:add, k, v}, state) do
    new_state = Map.put(state, k, v)
    {:ok, new_state}
  end

  def handlers_call({:remove, k}, state) do
    new_state = Map.delete(state, k)
    {:ok, new_state}
  end

  def handlers_call({:exist_key?, k}, state) do
    result = Map.has_key?(state, k)
    {result, state}
  end
end
