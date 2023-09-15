defmodule NaiveTcpServer do
  def start(port \\ 1234) do
    IO.puts("Start server on port #{port}")
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, {:active, true}])
    start_acceptor(listen_socket)
  end

  def start_acceptor(listen_socket) do
    # spawn(fn -> wait_for_client(listen_socket) end)
    spawn(__MODULE__, :wait_for_client, [listen_socket])
  end

  def wait_for_client(listen_socket) do
    IO.puts("Process #{inspect(self())} is waiting client")

    {:ok, accepten_socket} = :gen_tcp.accept(listen_socket)

    start_acceptor(listen_socket)

    IO.puts("Process #{inspect(self())} got client connection #{inspect(accepten_socket)}")
    # state = %{listen_socket: listen_socket}
    loop()
  end

  def loop() do
    IO.puts("Process #{inspect(self())} waiting data from client")

    receive do
      {:tcp, socket, data} ->
        IO.puts("Process #{inspect(self())} got data #{data}")
        :gen_tcp.send(socket, "Sever answer: #{data}")
        loop()

      {:tcp_closed, _socket} ->
        IO.puts("Client closed connection")

      msg ->
        IO.puts("Unknown message #{inspect(msg)}")
    end
  end
end
