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

  @ignore_names [".git", ".gitignore", ".idea", "_build", "deps", "log", "tmp", ".formatter.exs"]

  @ignore_extensions [".beam", ".lock", ".iml", ".log", ".pyc"]

  @max_depth 5

  def analyze(path) do
    files =
      get_files(path)
      |> Enum.filter(fn file -> Path.extname(file) not in @ignore_extensions end)

    f = fn exts -> Enum.filter(files, fn file -> Path.extname(file) in exts end) end

    types =
      @types
      |> Enum.map(fn {lang, exts} -> {lang, f.(exts)} end)

    extentions = @types |> Enum.reduce([], fn {_, exts}, acc -> acc ++ exts end)

    other =
      files |> Enum.filter(fn file -> Path.extname(file) not in extentions end)

    langs = types ++ [{"Other", other}]

    langs
    |> Enum.map(fn {lang, files} -> {lang, get_files_info(files)} end)
    |> Enum.reduce(%{}, fn {lang, stat}, acc -> Map.merge(acc, %{lang => stat}) end)
  end

  def get_files_info(files) do
    init_acc = %{files: 0, lines: 0, size: 0}

    reducer = fn path, %{files: files, lines: lines, size: size} ->
      {:ok, %{size: current_size}} = File.stat(path)
      {:ok, contents} = File.read(path)
      current_lines_count = contents |> String.split("\n") |> length
      %{files: files + 1, lines: lines + current_lines_count, size: size + current_size}
    end

    files
    |> Enum.reduce(init_acc, reducer)
  end

  def get_files(path) do
    # cond do
    #   File.regular?(path) ->
    #     [path]
    #
    #   File.dir?(path) ->
    #     File.ls!(path)
    #     |> Enum.map(&Path.join(path, &1))
    #     |> Enum.map(&get_files/1)
    #     |> Enum.concat true -> []
    # end

    Path.wildcard(path <> "/**/*.*")
  end
end

