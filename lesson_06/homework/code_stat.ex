defmodule CodeStat do
  @types [
    {"Elixir", [".ex", ".exs"]},
    {"Erlang", [".erl"]},
    {"Python", [".py"]},
    {"JavaScript", [".js"]},
    {"SQL", [".sql"]},
    {"JSON", [".json"]},
    {"Web", [".html", ".htm", ".css"]},
    {"Scripts", [".sh", ".lua", ".j2"]},
    {"Configs", [".yaml", ".yml", ".conf", ".args", ".env"]},
    {"Docs", [".md"]}
  ]

  @ignore_names [".git", ".gitignore", ".idea", "_build", "deps", "log", ".formatter.exs"]

  @ignore_extensions [".beam", ".lock", ".iml", ".log", ".pyc"]

  @max_depth 5

  def analyze(path) do
    files =
      get_files(path)
      |> Enum.filter(fn file ->
        Path.extname(file) not in @ignore_extensions and
          Path.basename(file) not in @ignore_names
      end)

    init =
      Enum.reduce(@types, %{}, fn {lang, _}, acc ->
        Map.put(acc, lang, %{files: 0, lines: 0, size: 0})
      end)

    combiner = fn file, acc ->
      {lang, %{files: f, lines: l, size: s} = stat} = get_file_info(file)

      Map.update(acc, lang, stat, fn value ->
        %{files: files, lines: lines, size: size} = value
        %{files: files + f, lines: lines + l, size: size + s}
      end)
    end

    files |> Enum.reduce(init, combiner)
  end

  def get_type_file(path) do
    ext = Path.extname(path)
    lang = @types |> Enum.filter(fn {_, exts} -> ext in exts end)

    case lang do
      [{lg, _}] -> lg
      [] -> "Other"
    end
  end

  def get_file_info(path) do
    {:ok, %{size: size}} = File.stat(path)
    {:ok, contents} = File.read(path)
    lines_count = contents |> String.split("\n") |> length
    type = get_type_file(path)

    {type, %{files: 1, lines: lines_count, size: size}}
  end

  def get_files(path) do
    cond do
      File.regular?(path) ->
        [path]

      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&get_files/1)
        |> List.flatten()
    end
  end
end
