defmodule PhxStats.FormatterTest do
  use ExUnit.Case, async: true

  alias PhxStats.Formatter

  defp stats(overrides) do
    Map.merge(%{files: 1, lines: 10, loc: 8, modules: 1, functions: 2}, overrides)
  end

  test "renders a table with header, separators, rows, total, and summary" do
    report = %{
      categories: [{"Controllers", stats(%{lines: 100, loc: 80, modules: 2, functions: 10})}],
      total: stats(%{lines: 100, loc: 80, modules: 2, functions: 10}),
      tests: stats(%{loc: 40})
    }

    output = Formatter.format(report)

    assert output =~ "| Name"
    assert output =~ "Controllers"
    assert output =~ "Total"
    assert output =~ "Code LOC: 80"
    assert output =~ "Test LOC: 40"
    assert output =~ "Code to Test Ratio: 1:0.5"
  end

  test "handles zero modules and zero functions without dividing by zero" do
    empty_total = %{files: 0, lines: 0, loc: 0, modules: 0, functions: 0}
    report = %{categories: [], total: empty_total, tests: empty_total}

    output = Formatter.format(report)

    assert output =~ "Code to Test Ratio: 1:0.0"
    assert output =~ "Total"
  end

  test "name column widens to fit long category names while staying aligned" do
    long_name = "Background Workers and Mailers"

    report = %{
      categories: [{long_name, stats(%{lines: 1, loc: 1, modules: 1, functions: 1})}],
      total: stats(%{lines: 1, loc: 1, modules: 1, functions: 1}),
      tests: stats(%{})
    }

    output = Formatter.format(report)
    lines = String.split(output, "\n", trim: true)

    assert Enum.any?(lines, &String.contains?(&1, long_name))

    table_lines = Enum.filter(lines, &String.starts_with?(&1, ["+", "|"]))
    [first_width | _] = widths = Enum.map(table_lines, &String.length/1)
    assert Enum.all?(widths, &(&1 == first_width)),
           "expected uniform table width, got: #{inspect(widths)}"
  end

  test "numeric column widens to fit large values" do
    big = stats(%{lines: 1_234_567, loc: 1_000_000, modules: 1234, functions: 56789})

    report = %{
      categories: [{"Lib", big}],
      total: big,
      tests: stats(%{loc: 100})
    }

    output = Formatter.format(report)
    lines = String.split(output, "\n", trim: true)

    assert Enum.any?(lines, &String.contains?(&1, "1234567"))

    table_lines = Enum.filter(lines, &String.starts_with?(&1, ["+", "|"]))
    [first_width | _] = widths = Enum.map(table_lines, &String.length/1)
    assert Enum.all?(widths, &(&1 == first_width))
  end
end
