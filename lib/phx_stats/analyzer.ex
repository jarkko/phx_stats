defmodule PhxStats.Analyzer do
  @moduledoc """
  Pure analysis functions: count lines, modules, and functions in Elixir source files.
  """

  @type stats :: %{
          files: non_neg_integer(),
          lines: non_neg_integer(),
          loc: non_neg_integer(),
          modules: non_neg_integer(),
          functions: non_neg_integer()
        }

  @type category_result :: {String.t(), stats()}

  @type report :: %{
          categories: [category_result()],
          total: stats(),
          tests: stats()
        }

  @empty %{files: 0, lines: 0, loc: 0, modules: 0, functions: 0}

  @doc """
  Builds a full report given a list of `{name, glob}` categories and a test glob.

  Each source file is assigned to the **first** category whose glob matches it,
  so overlapping patterns do not double-count. Categories that end up with no
  files are dropped. The total excludes test files — tests are counted
  separately so the code-to-test ratio is meaningful.
  """
  @spec analyze([{String.t(), String.t()}], String.t()) :: report()
  def analyze(categories, test_pattern) do
    {category_stats, _assigned} =
      Enum.reduce(categories, {[], MapSet.new()}, fn {name, pattern}, {acc, taken} ->
        files =
          pattern
          |> find_files()
          |> Enum.reject(&MapSet.member?(taken, &1))

        case files do
          [] ->
            {acc, taken}

          _ ->
            stats = files |> Enum.map(&analyze_file/1) |> sum_stats()
            {[{name, stats} | acc], MapSet.union(taken, MapSet.new(files))}
        end
      end)

    category_stats = Enum.reverse(category_stats)
    test_stats = analyze_pattern(test_pattern)

    total =
      category_stats
      |> Enum.map(fn {_name, stats} -> stats end)
      |> sum_stats()

    %{categories: category_stats, total: total, tests: test_stats}
  end

  @doc "Analyzes all files matching a wildcard pattern."
  @spec analyze_pattern(String.t()) :: stats()
  def analyze_pattern(pattern) do
    pattern
    |> find_files()
    |> Enum.map(&analyze_file/1)
    |> sum_stats()
  end

  @doc "Analyzes a single file. Returns zeroed stats if the file cannot be read."
  @spec analyze_file(Path.t()) :: stats()
  def analyze_file(file) do
    case File.read(file) do
      {:ok, content} -> analyze_content(content)
      {:error, _} -> @empty
    end
  end

  @doc "Analyzes a string of Elixir source code."
  @spec analyze_content(String.t()) :: stats()
  def analyze_content(content) do
    lines = String.split(content, "\n")

    loc = Enum.count(lines, fn line -> not blank_or_comment?(line) end)

    %{
      files: 1,
      lines: length(lines),
      loc: loc,
      modules: count_lines_matching(lines, ~r/^\s*defmodule\s/),
      functions: count_lines_matching(lines, ~r/^\s*def(p|macro|macrop)?\s/)
    }
  end

  @spec sum_stats([stats()]) :: stats()
  def sum_stats(stats_list) do
    Enum.reduce(stats_list, @empty, fn s, acc ->
      %{
        files: acc.files + s.files,
        lines: acc.lines + s.lines,
        loc: acc.loc + s.loc,
        modules: acc.modules + s.modules,
        functions: acc.functions + s.functions
      }
    end)
  end

  defp find_files(pattern) do
    pattern
    |> Path.wildcard(match_dot: false)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp blank_or_comment?(line) do
    trimmed = String.trim(line)
    trimmed == "" or String.starts_with?(trimmed, "#")
  end

  defp count_lines_matching(lines, pattern) do
    Enum.count(lines, &Regex.match?(pattern, &1))
  end
end
