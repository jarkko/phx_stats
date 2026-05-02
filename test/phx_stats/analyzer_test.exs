defmodule PhxStats.AnalyzerTest do
  use ExUnit.Case, async: true

  alias PhxStats.Analyzer

  describe "analyze_content/1" do
    test "counts lines, LOC, modules, and functions" do
      content = """
      defmodule Foo do
        # a comment

        def bar, do: :ok

        defp baz(x) do
          x + 1
        end
      end
      """

      stats = Analyzer.analyze_content(content)

      assert stats.files == 1
      assert stats.modules == 1
      assert stats.functions == 2
      assert stats.lines == String.split(content, "\n") |> length()
      assert stats.loc < stats.lines
      assert stats.loc > 0
    end

    test "ignores blank lines and comments when computing LOC" do
      content = "# comment\n\n   \ndef a, do: 1\n"
      stats = Analyzer.analyze_content(content)
      assert stats.loc == 1
    end

    test "counts defmacro and defmacrop as functions" do
      content = """
      defmodule M do
        defmacro a, do: :ok
        defmacrop b, do: :ok
      end
      """

      stats = Analyzer.analyze_content(content)
      assert stats.functions == 2
    end

    test "does not count `defmodule` lines as functions" do
      stats = Analyzer.analyze_content("defmodule Foo do\nend\n")
      assert stats.modules == 1
      assert stats.functions == 0
    end

    test "does not match `define` or other `def`-prefixed identifiers" do
      stats = Analyzer.analyze_content("define_thing :ok\ndefstruct foo: 1\n")
      assert stats.functions == 0
    end

    test "empty content yields zero LOC and one file" do
      stats = Analyzer.analyze_content("")
      assert stats.files == 1
      assert stats.loc == 0
      assert stats.modules == 0
      assert stats.functions == 0
    end
  end

  @empty_stats %{files: 0, lines: 0, loc: 0, modules: 0, functions: 0}

  describe "analyze_file/1" do
    test "returns empty stats when file is missing" do
      assert Analyzer.analyze_file("does/not/exist.ex") == @empty_stats
    end
  end

  describe "sum_stats/1" do
    test "sums all fields and returns empty for an empty list" do
      assert Analyzer.sum_stats([]) == @empty_stats

      a = %{files: 1, lines: 10, loc: 8, modules: 1, functions: 2}
      b = %{files: 2, lines: 30, loc: 25, modules: 3, functions: 5}

      assert Analyzer.sum_stats([a, b]) ==
               %{files: 3, lines: 40, loc: 33, modules: 4, functions: 7}
    end
  end

  describe "analyze/2 (integration with the file system)" do
    setup do
      tmp = Path.join(System.tmp_dir!(), "phx_stats_#{System.unique_integer([:positive])}")
      File.mkdir_p!(Path.join(tmp, "lib/app/controllers"))
      File.mkdir_p!(Path.join(tmp, "test"))

      File.write!(Path.join(tmp, "lib/app/controllers/page_controller.ex"), """
      defmodule App.PageController do
        def index(conn, _), do: conn
      end
      """)

      File.write!(Path.join(tmp, "test/page_test.exs"), """
      defmodule App.PageTest do
        use ExUnit.Case
        test "ok", do: assert true
      end
      """)

      on_exit(fn -> File.rm_rf!(tmp) end)

      {:ok, tmp: tmp}
    end

    test "produces a report keyed by category name with non-empty buckets only", %{tmp: tmp} do
      File.cd!(tmp, fn ->
        report =
          Analyzer.analyze(
            [
              {"Controllers", "lib/**/controllers/**/*.ex"},
              {"Empty", "lib/**/nope/**/*.ex"}
            ],
            "test/**/*_test.exs"
          )

        names = Enum.map(report.categories, fn {name, _} -> name end)
        assert "Controllers" in names
        refute "Empty" in names

        assert report.total.files == 1
        assert report.tests.files == 1
      end)
    end
  end
end
