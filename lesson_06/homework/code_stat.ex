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

    analyze(path, initial)
  end

  def analyze(path, acc) do
    cond do
      Path.basename(path) in @ignore_names ->
        %{}

      Path.extname(path) in @ignore_extensions ->
        %{}

      File.regular?(path) ->
        file_stat = get_file_info(path)
        Map.merge(acc, file_stat, &merge_stat/3)

      File.dir?(path) ->
        File.ls!(path)
        # |> Enum.map(fn dir -> Path.join(path, dir) end)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.reduce(
          acc,
          fn dir, nested ->
            Map.merge(nested, analyze(dir, acc), &merge_stat/3)
          end
        )
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

  # def _analyze(path) do
  #   initial =
  #     Enum.reduce(@types, %{}, fn {lang, _}, acc ->
  #       Map.put(acc, lang, %{files: 0, lines: 0, size: 0})
  #     end)
  #
  #   traversal(get_files(path), initial)
  # end

  # def get_files(path) do
  #   cond do
  #     Path.basename(path) in @ignore_names ->
  #       %{}
  #
  #     Path.extname(path) in @ignore_extensions ->
  #       %{}
  #
  #     File.regular?(path) ->
  #       get_file_info(path)
  #
  #     File.dir?(path) ->
  #       File.ls!(path)
  #       |> Enum.map(&Path.join(path, &1))
  #       |> Enum.map(&get_files/1)
  #   end
  # end
  #
  # def traversal([], acc), do: acc
  #
  # def traversal([[head | children] | siblings], acc) do
  #   new_acc = Map.merge(acc, head, &merge_lang/3)
  #
  #   traversal(siblings ++ children, new_acc)
  # end
  #
  # def traversal([head | tail], acc) do
  #   new_acc = Map.merge(acc, head, &merge_lang/3)
  #   traversal(tail, new_acc)
  # end
end
