defmodule FindElixirSource do
  @file_name "../../elixir_course/lesson_11/lib"

  def start() do
    {:ok, supervisor_pid} = Task.Supervisor.start_link()
    IO.puts("supervisor: #{inspect(supervisor_pid)}")
    Task.Supervisor.async(supervisor_pid, __MODULE__, :find, [@file_name])
    # Task.async(fn -> find(@file_name) end)
  end

  def get_result(task) do
    Task.await(task)
  end

  def find(path) do
    {result, _status} = System.cmd("find", [path, "-name", "\*.exs", "-o", "-name", "\*.ex"])
    result |> String.split()
  end
end
