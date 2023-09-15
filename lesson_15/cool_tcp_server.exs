defmodule CoolTcpServer do
  @modoledoc """
  - RootSup
    - Listener
    - AcceptorSup
      - Acceptor
  """

  def start() do
    IO.puts("CoolTcpServer.start from #{inspect(self())}")
    CoolTcpServer.RootSup.start_link(:no_args)
  end

  defmodule RootSup do
    use Supervisor

    def start_link(_) do
      Supervisor.start_link(__MODULE__, :no_args)
    end

    @impl true
    def init(_) do
      port = 3000

      child_spec = [
        {CoolTcpServer.Listener, port}
      ]

      Supervisor.init(child_spec, strategy: :rest_for_one)
    end
  end

  defmodule Listener do
    use GenServer

    def start_link(port) do
      GenServer.start_link(__MODULE__, port)
    end

    @impl true
    def init(port) do
      state = %{port: port}
      IO.puts("Start Listener with state #{inspect(state)}")
      {:ok, state}
    end
  end

  defmodule Acceptor do
    use GenServer

    def start_link(listening_socket) do
      GenServer.start_link(__MODULE__, listening_socket)
    end

    @impl true
    def init(listening_socket) do
      state = %{listening_socket: listening_socket}
      IO.puts("Start Acceptor with state #{inspect(state)}")
      {:ok, state}
    end
  end
end
