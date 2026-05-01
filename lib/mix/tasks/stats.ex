defmodule Mix.Tasks.Stats do
  @moduledoc """
  Displays code statistics for the current project.

  Inspired by Rails' `rake stats`, this prints lines of code, number of
  modules and functions, and a code-to-test ratio, broken down by category.

  ## Usage

      $ mix stats

  ## Configuration

  Categories and the test glob are configurable. Add to your `config/config.exs`:

      config :phx_stats,
        categories: [
          {"Controllers", "lib/**/controllers/**/*.ex"},
          {"LiveViews", "lib/**/live/**/*.ex"},
          {"Contexts", "lib/my_app/*.ex"}
        ],
        test_pattern: "test/**/*_test.exs"

  Without configuration, sensible Phoenix defaults are used. See
  `PhxStats.Config` for details.

  ## Example output

      +----------------------+--------+--------+---------+---------+-----+-------+
      | Name                 |  Lines |    LOC | Modules |   Funcs | F/M | LOC/F |
      +----------------------+--------+--------+---------+---------+-----+-------+
      | Controllers          |   1234 |    890 |      12 |     123 |  10 |     7 |
      | LiveViews            |   2345 |   1789 |      23 |     234 |  10 |     7 |
      +----------------------+--------+--------+---------+---------+-----+-------+
      | Total                |   3579 |   2679 |      35 |     357 |  10 |     7 |
      +----------------------+--------+--------+---------+---------+-----+-------+
        Code LOC: 2679     Test LOC: 1234     Code to Test Ratio: 1:0.5
  """

  use Mix.Task

  alias PhxStats.{Analyzer, Config, Formatter}

  @shortdoc "Shows code statistics for the project"

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(_args) do
    Config.categories()
    |> Analyzer.analyze(Config.test_pattern())
    |> Formatter.format()
    |> IO.puts()
  end
end
