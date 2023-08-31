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
    initial =
      Enum.reduce(@types, %{}, fn {lang, _}, acc ->
        Map.put(acc, lang, %{files: 0, lines: 0, size: 0})
      end)

    {:ok, items} = File.ls(path)

    items
    |> Enum.filter(fn item ->
      Path.basename(item) not in @ignore_names and
        Path.extname(item) not in @ignore_extensions
    end)
    |> Enum.reduce(
      initial,
      fn item, acc ->
        Map.merge(acc, traversal(path, item), &merge_stat/3)
      end
    )
  end

  def traversal(path, item) do
    full_path = Path.join(path, item)

    cond do
      File.regular?(full_path) ->
        get_file_info(full_path)

      File.dir?(full_path) ->
        analyze(full_path)
    end
  end

  def merge_stat(_k, v1, v2) do
    %{files: f1, lines: l1, size: s1} = v1
    %{files: f2, lines: l2, size: s2} = v2
    %{files: f1 + f2, lines: l1 + l2, size: s1 + s2}
  end

  def get_file_info(path) do
    {:ok, %{size: size}} = File.stat(path)
    {:ok, contents} = File.read(path)
    lines_count = contents |> String.split("\n") |> length
    type = get_type_file(path)

    %{type => %{files: 1, lines: lines_count, size: size}}
  end

  def get_type_file(path) do
    ext = Path.extname(path)
    lang = @types |> Enum.filter(fn {_, exts} -> ext in exts end)

    case lang do
      [{lg, _}] -> lg
      [] -> "Other"
    end
  end
end
