defmodule PhxStats.Formatter do
  @moduledoc """
  Renders an analysis report as an ASCII table plus a summary line.
  """

  alias PhxStats.Analyzer

  @separator "+----------------------+--------+--------+---------+---------+-----+-------+"
  @header "| Name                 |  Lines |    LOC | Modules |   Funcs | F/M | LOC/F |"

  @doc "Returns the report as a printable string."
  @spec format(Analyzer.report()) :: String.t()
  def format(%{categories: categories, total: total, tests: tests}) do
    rows =
      categories
      |> Enum.map(fn {name, stats} -> row(name, stats) end)
      |> Enum.join("\n")

    body = [
      "",
      @separator,
      @header,
      @separator,
      rows,
      @separator,
      row("Total", total),
      @separator,
      summary(total, tests),
      ""
    ]

    Enum.join(body, "\n")
  end

  defp row(name, stats) do
    funcs_per_module = if stats.modules > 0, do: div(stats.functions, stats.modules), else: 0
    loc_per_func = if stats.functions > 0, do: div(stats.loc, stats.functions), else: 0

    "| #{pad_right(name, 20)} | #{pad_left(stats.lines, 6)} | #{pad_left(stats.loc, 6)} | " <>
      "#{pad_left(stats.modules, 7)} | #{pad_left(stats.functions, 7)} | " <>
      "#{pad_left(funcs_per_module, 3)} | #{pad_left(loc_per_func, 5)} |"
  end

  defp summary(total, tests) do
    ratio = if total.loc > 0, do: Float.round(tests.loc / total.loc, 1), else: 0.0
    "  Code LOC: #{total.loc}     Test LOC: #{tests.loc}     Code to Test Ratio: 1:#{ratio}"
  end

  defp pad_left(value, width) when is_integer(value),
    do: value |> to_string() |> String.pad_leading(width)

  defp pad_left(value, width) when is_binary(value),
    do: String.pad_leading(value, width)

  defp pad_right(value, width), do: String.pad_trailing(value, width)
end
