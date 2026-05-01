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
end
