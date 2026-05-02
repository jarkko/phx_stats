defmodule PhxStats.Formatter do
  @moduledoc """
  Renders an analysis report as an ASCII table plus a summary line.

  Column widths are computed from the data so long category names and
  large numbers stay aligned with the separator.
  """

  alias PhxStats.Analyzer

  @columns [
    {:name, "Name", :left},
    {:lines, "Lines", :right},
    {:loc, "LOC", :right},
    {:modules, "Modules", :right},
    {:functions, "Funcs", :right},
    {:funcs_per_module, "F/M", :right},
    {:loc_per_func, "LOC/F", :right}
  ]

  @min_widths %{
    name: 4,
    lines: 6,
    loc: 6,
    modules: 7,
    functions: 7,
    funcs_per_module: 3,
    loc_per_func: 5
  }

  @doc "Returns the report as a printable string."
  @spec format(Analyzer.report()) :: String.t()
  def format(%{categories: categories, total: total, tests: tests}) do
    rows = Enum.map(categories, fn {name, stats} -> row_values(name, stats) end)
    total_row = row_values("Total", total)

    widths = compute_widths([total_row | rows])
    separator = build_separator(widths)
    header = build_header(widths)

    body =
      [
        "",
        separator,
        header,
        separator
      ] ++
        Enum.map(rows, &render_row(&1, widths)) ++
        [
          separator,
          render_row(total_row, widths),
          separator,
          summary(total, tests),
          ""
        ]

    Enum.join(body, "\n")
  end

  defp row_values(name, stats) do
    funcs_per_module = if stats.modules > 0, do: div(stats.functions, stats.modules), else: 0
    loc_per_func = if stats.functions > 0, do: div(stats.loc, stats.functions), else: 0

    %{
      name: name,
      lines: stats.lines,
      loc: stats.loc,
      modules: stats.modules,
      functions: stats.functions,
      funcs_per_module: funcs_per_module,
      loc_per_func: loc_per_func
    }
  end

  defp compute_widths(rows) do
    Map.new(@columns, fn {key, header, _align} ->
      data_width =
        rows
        |> Enum.map(&(&1 |> Map.fetch!(key) |> to_string() |> String.length()))
        |> Enum.max(fn -> 0 end)

      width =
        [String.length(header), data_width, Map.fetch!(@min_widths, key)]
        |> Enum.max()

      {key, width}
    end)
  end

  defp build_separator(widths) do
    parts = Enum.map(@columns, fn {key, _header, _align} -> String.duplicate("-", widths[key] + 2) end)
    "+" <> Enum.join(parts, "+") <> "+"
  end

  defp build_header(widths) do
    cells =
      Enum.map(@columns, fn {key, header, align} ->
        pad(header, widths[key], align)
      end)

    "| " <> Enum.join(cells, " | ") <> " |"
  end

  defp render_row(values, widths) do
    cells =
      Enum.map(@columns, fn {key, _header, align} ->
        pad(to_string(values[key]), widths[key], align)
      end)

    "| " <> Enum.join(cells, " | ") <> " |"
  end

  defp summary(total, tests) do
    ratio = if total.loc > 0, do: Float.round(tests.loc / total.loc, 1), else: 0.0
    "  Code LOC: #{total.loc}     Test LOC: #{tests.loc}     Code to Test Ratio: 1:#{ratio}"
  end

  defp pad(value, width, :left), do: String.pad_trailing(value, width)
  defp pad(value, width, :right), do: String.pad_leading(value, width)
end
