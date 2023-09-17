defmodule TcpClien do
  use GenServer

  def start() do
    start_link(:no_args)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
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
    IO.puts("TCP Cliend connected #{inspect(host)} #{port}")
    state = %{socket: socket}
    {:ok, state}
  end
end
