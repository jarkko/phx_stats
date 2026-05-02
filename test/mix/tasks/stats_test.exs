defmodule Mix.Tasks.StatsTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    tmp = Path.join(System.tmp_dir!(), "phx_stats_task_#{System.unique_integer([:positive])}")
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

  test "--help prints usage and does not run analysis" do
    output =
      capture_io(fn ->
        Mix.Tasks.Stats.run(["--help"])
      end)

    assert output =~ "## Usage"
    assert output =~ "## Options"
    # No actual analysis ran — only the moduledoc, no live separator with totals.
    refute output =~ ~r/^Code LOC:/m
  end

  test "--category overrides the configured categories", %{tmp: tmp} do
    File.cd!(tmp, fn ->
      output =
        capture_io(fn ->
          Mix.Tasks.Stats.run([
            "--category",
            "Controllers=lib/**/controllers/**/*.ex",
            "--test-pattern",
            "test/**/*_test.exs"
          ])
        end)

      assert output =~ "Controllers"
      assert output =~ "Code to Test Ratio"
    end)
  end

  test "--test-pattern overrides the configured test glob", %{tmp: tmp} do
    File.cd!(tmp, fn ->
      output =
        capture_io(fn ->
          Mix.Tasks.Stats.run([
            "--category",
            "Controllers=lib/**/*.ex",
            "--test-pattern",
            "test/**/*_test.exs"
          ])
        end)

      assert output =~ ~r/Test LOC: \d+/
      assert output =~ "Code to Test Ratio"
    end)
  end

  test "invalid --category spec raises a clear error" do
    assert_raise Mix.Error, ~r/invalid --category/, fn ->
      Mix.Tasks.Stats.run(["--category", "no-equals-sign"])
    end
  end

  test "unknown option raises" do
    assert_raise Mix.Error, ~r/unknown option/, fn ->
      Mix.Tasks.Stats.run(["--bogus"])
    end
  end
end
