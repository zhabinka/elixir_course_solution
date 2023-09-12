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
      priv_dir = Application.app_dir(:path_finder_service, "priv")
      file_name = Path.join(priv_dir, "cities.csv")

      child_spec = [
        {PathFinder, file_name}
      ]

      IO.puts("RootSup.init, child_spec: #{inspect(child_spec)}")
      Supervisor.init(child_spec, strategy: :one_for_one)
    end
  end
end
