defmodule PathFinderService do
  use Application

  @impl true
  def start(_, _) do
    IO.puts("Application start_link")
    PathFinderService.RootSup.start_link(:no_args)
  end

  defmodule RootSup do
    use Supervisor

    def start_link(:no_args) do
      IO.puts("RootSup start_link")
      Supervisor.start_link(__MODULE__, :no_args)
    end

    @impl true
    def init(:no_args) do
      child_spec = [
        {
          PathFinder,
          "./priv/cities.csv"
        }
      ]

      IO.puts("RootSup.init, child_spec: #{inspect(child_spec)}")
      Supervisor.init(child_spec, strategy: :one_for_one)
    end
  end
end
