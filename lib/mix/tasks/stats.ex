defmodule Mix.Tasks.Stats do
  @moduledoc """
  Displays code statistics for the current project.

  Inspired by Rails' `rake stats`, this prints lines of code, number of
  modules and functions, and a code-to-test ratio, broken down by category.

  ## Usage

      $ mix stats
      $ mix stats --test-pattern "test/**/*_test.exs"
      $ mix stats --category "Workers=lib/**/workers/**/*.ex" \\
                  --category "Libraries=lib/**/*.ex"

  ## Options

    * `--test-pattern PATTERN` — override the configured test glob.
    * `--category NAME=GLOB` — replace the configured category list.
      Repeat the flag once per category; first-match-wins ordering applies.
      If no `--category` flag is given, the configured categories are used.
    * `--help`, `-h` — show this help and exit.

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

  @switches [test_pattern: :string, category: :keep, help: :boolean]
  @aliases [h: :help]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    {opts, rest, invalid} = OptionParser.parse(args, strict: @switches, aliases: @aliases)

    cond do
      invalid != [] ->
        Mix.raise(
          "phx_stats: unknown option(s): " <>
            Enum.map_join(invalid, ", ", fn {flag, _} -> flag end) <>
            ". Run `mix help stats` for usage."
        )

      rest != [] ->
        Mix.raise(
          "phx_stats: unexpected argument(s): " <>
            Enum.join(rest, ", ") <> ". Run `mix help stats` for usage."
        )

      opts[:help] ->
        Mix.shell().info(@moduledoc)
        :ok

      true ->
        [categories: resolve_categories(opts), test_pattern: resolve_test_pattern(opts)]
        |> Analyzer.analyze()
        |> Formatter.format()
        |> IO.puts()
    end
  end

  defp resolve_categories(opts) do
    case Keyword.get_values(opts, :category) do
      [] -> Config.categories()
      values -> Enum.map(values, &parse_category/1)
    end
  end

  defp parse_category(spec) do
    case String.split(spec, "=", parts: 2) do
      [name, glob] when name != "" and glob != "" ->
        {name, glob}

      _ ->
        Mix.raise(
          "phx_stats: invalid --category #{inspect(spec)}, expected NAME=GLOB"
        )
    end
  end

  defp resolve_test_pattern(opts) do
    Keyword.get(opts, :test_pattern, Config.test_pattern())
  end
end
