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
      options = %{
        port: 3000,
        pool_size: 5
      }

      child_spec = [
        {CoolTcpServer.AcceptorSup, :no_args},
        {CoolTcpServer.Listener, options}
      ]

      Supervisor.init(child_spec, strategy: :rest_for_one)
    end
  end

  defmodule Listener do
    use GenServer

    def start_link(options) do
      GenServer.start_link(__MODULE__, options)
    end

    @impl true
    def init(options) do
      state = %{
        port: Map.get(options, :port, 1234),
        pool_size: Map.get(options, :pool_size, 50)
      }

      socket_options = [
        :binary,
        {:active, false},
        {:packet, 2},
        {:reuseaddr, true}
      ]

      {:ok, listening_socket} = :gen_tcp.listen(state.port, socket_options)
      state = Map.put(state, :listening_socket, listening_socket)
      IO.puts("Start Listener on with state #{inspect(state)}")

      1..state.pool_size
      |> Enum.each(fn id -> CoolTcpServer.AcceptorSup.start_acceptor(id, listening_socket) end)

      {:ok, state}
    end
  end

  defmodule AcceptorSup do
    use DynamicSupervisor

    @name :acceptor_sup

    def start_link(_) do
      DynamicSupervisor.start_link(__MODULE__, :no_args, name: @name)
    end

    @impl true
    def init(_) do
      DynamicSupervisor.init(strategy: :one_for_one)
    end

    def start_acceptor(id, listening_socket) do
      child_spec = {CoolTcpServer.Acceptor, {id, listening_socket}}

      DynamicSupervisor.start_child(@name, child_spec)
    end
  end

  defmodule Acceptor do
    use GenServer

    def start_link(args) do
      GenServer.start_link(__MODULE__, args)
    end

    @impl true
    def init({id, listening_socket}) do
      state = %{
        id: id,
        listening_socket: listening_socket
      }

      IO.puts("Start Acceptor #{state.id} with state #{inspect(state)}")
      {:ok, state, {:continue, :wait_for_client}}
    end

    @impl true
    def handle_continue(:wait_for_client, state) do
      IO.puts("Acceptor #{state.id} is waiting client")
      {:ok, socket} = :gen_tcp.accept(state.listening_socket)
      IO.puts("Acceptor #{state.id} got client connection #{inspect(socket)}")
      state = Map.put(state, :socket, socket)
      {:noreply, state, {:continue, :receive_data}}
    end

    def handle_continue(:receive_data, state) do
      IO.puts("Acceptor #{state.id} is waiting data")

      case :gen_tcp.recv(state.socket, 0) do
        {:ok, data} ->
          data = :erlang.binary_to_term(data)
          IO.puts("Acceptor #{state.id} got data #{inspect(data)}")

          response = %{
            success: true,
            request: data
          }

          response_binary = :erlang.term_to_binary(response)

          :gen_tcp.send(state.socket, response_binary)
          {:noreply, state, {:continue, :receive_data}}

        {:error, error} ->
          IO.puts("Acceptor #{state.id} got error #{inspect(error)}")
          :gen_tcp.close(state.socket)
          {:noreply, state, {:continue, :wait_for_client}}
      end
    end

    # Catch all
    def handle_continue(msg, state) do
      IO.puts("Acceptor #{state.id} got unknown message #{inspect(msg)}")
      {:noreply, state}
    end

    @impl true
    def handle_info({:tcp, socket, "quit" <> _}, state) do
      :gen_tcp.close(socket)
      IO.puts("Server closed connection")
      {:noreply, state, {:continue, :wait_for_client}}
    end

    def handle_info({:tcp, socket, msg}, state) do
      :gen_tcp.send(socket, "Server answer: #{inspect(msg)}\n")
      {:noreply, state}
    end

    def handle_info({:tcp_closed, socket}, state) do
      :gen_tcp.close(socket)
      IO.puts("Client #{inspect(socket)} closed connection")
      {:noreply, state, {:continue, :wait_for_client}}
    end

    # Catch all
    def handle_info(msg, state) do
      IO.puts("Acceptor #{state.id} got unknown message '#{inspect(msg)}'")
      {:noreply, state}
    end
  end
end
