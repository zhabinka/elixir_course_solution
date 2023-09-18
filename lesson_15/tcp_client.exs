defmodule TcpClient do
  use GenServer

  def start() do
    start_link(:no_args)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: :client)
  end

  def send_data(data) do
    GenServer.call(:client, {:send, data})
  end

  @impl true
  def init(:no_args) do
    host = {127, 0, 0, 1}
    port = 3000

    options = [
      :binary,
      {:active, true},
      {:packet, :raw}
    ]

    IO.puts("TCP Client started")
    {:ok, socket} = :gen_tcp.connect(host, port, options)
    IO.puts("TCP Cliend connected to #{inspect(host)} port #{port}")
    state = %{socket: socket}
    {:ok, state}
  end

  @impl true
  def handle_call({:send, data}, _from, state) do
    bin_data = :erlang.term_to_binary(data)
    size = byte_size(bin_data)
    header = <<size::16>>
    IO.puts("Client prepared data: header #{inspect(header)}, data #{inspect(bin_data)}")
    :gen_tcp.send(state.socket, header <> bin_data)
    IO.puts("Client send #{inspect(data)} to #{inspect(state.socket)}")
    {:reply, :ok, state}
  end

  # Catch all
  def handle_call(message, _from, state) do
    IO.puts("handle_call got unknown message #{inspect(message)}")
    {:reply, :error, state}
  end

  @impl true
  def handle_info({:tcp, socket, data_binary}, state) do
    <<_header::16, rest::binary>> = data_binary
    data = :erlang.binary_to_term(rest)
    IO.puts("Client got data #{inspect(data)} from #{inspect(socket)}")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts("handle_info got unknown message #{inspect(msg)}")
    {:noreply, state}
  end
end
