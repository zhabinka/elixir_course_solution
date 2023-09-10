defmodule PathFinder do
  @file_name "./data/cities.csv"
  @server_name :path_finder

  use GenServer

  # Client API
  def start() do
    IO.puts("#{@server_name} start from #{inspect(self())}")
    GenServer.start(__MODULE__, @file_name, name: @server_name)
  end

  def get_route(from, to) do
    GenServer.call(@server_name, {:get_route, from, to})
  end

  def reload_data() do
    GenServer.cast(@server_name, :reload_data)
  end

  # Server Callbacks
  def init(file_name) do
    state = %{data_file: file_name}
    IO.puts("init in server process #{inspect(self())}")
    IO.inspect(state)
    {:ok, state, {:continue, :delayed_init}}
  end

  def handle_continue(:delayed_init, state) do
    %{data_file: data_file} = state
    new_state = init_state(data_file)
    IO.puts("handle_continue in server process #{inspect(self())}")
    IO.inspect(new_state)
    {:noreply, new_state}
  end

  def handle_call({:get_route, from_city, to_city}, _from, state) do
    %{graph: graph, distances: distances} = state

    route =
      case :digraph.get_short_path(graph, from_city, to_city) do
        false -> []
        path -> path
      end

    dist = get_distance(route, distances)

    {:reply, {route, dist}, state}
  end

  # Catch all
  def handle_call(msg, from, state) do
    IO.puts("Server received unknown message #{inspect(msg)} from #{inspect(from)}")
    {:reply, {:error, :invalid_request}, state}
  end

  def handle_cast(:reload_data, state) do
    IO.puts("Start reload...")
    %{graph: graph, data_file: data_file} = state
    :digraph.delete(graph)
    new_state = init_state(data_file)
    IO.puts("Reload completed")
    {:noreply, new_state}
  end

  # Catch all
  def handle_cast(msg, state) do
    IO.puts("Server received unknown message #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts("Server got message #{inspect(msg)}")
    {:noreply, state}
  end

  def init_state(file) do
    graph = :digraph.new([:cyclic])

    paths = load_csv_data(file)
    Enum.each(paths, fn item -> init_graph(graph, item) end)

    distances = init_distances(paths)

    %{
      graph: graph,
      distances: distances,
      data_file: @file_name
    }
  end

  def init_graph(graph, {sity1, sity2, _dist}) do
    :digraph.add_vertex(graph, sity1)
    :digraph.add_vertex(graph, sity2)
    :digraph.add_edge(graph, sity1, sity2)
    :digraph.add_edge(graph, sity2, sity1)
  end

  def load_csv_data(file) do
    File.read!(file)
    |> String.split()
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [sity1, sity2, dist] = String.split(line, ",")
    {dist, ""} = Integer.parse(dist)
    {sity1, sity2, dist}
  end

  def init_distances(paths) do
    Enum.reduce(paths, %{}, fn {city1, city2, dist}, acc ->
      key = make_key(city1, city2)
      Map.put(acc, key, dist)
    end)
  end

  def make_key(k1, k2) do
    [k1, k2] |> Enum.sort() |> List.to_tuple()
  end

  def get_distance([], _distances), do: 0

  def get_distance(route, distances) do
    [first_city | rest] = route

    # Enum.zip(route, rest)
    # |> Enum.map(fn {city1, city2} ->
    #   Map.get(distances, make_key(city1, city2))
    # end)
    # |> Enum.sum()

    Enum.reduce(rest, {first_city, 0}, fn city, {prev_city, total_dist} ->
      key = make_key(city, prev_city)
      dist = Map.get(distances, key)
      {city, total_dist + dist}
    end)
    |> elem(1)
  end
end
