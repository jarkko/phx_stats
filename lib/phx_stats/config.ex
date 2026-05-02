defmodule PhxStats.Config do
  @moduledoc """
  Configuration for `mix stats`.

  ## Configuration

  Add to your `config/config.exs`:

      config :phx_stats,
        categories: [
          {"Controllers", "lib/**/controllers/**/*.ex"},
          {"Contexts", "lib/my_app/*.ex"}
        ],
        test_pattern: "test/**/*_test.exs"

  Each source file is assigned to the **first** category whose glob matches it,
  so overlapping patterns are safe — list more specific categories first and
  use a broad fallback (e.g. `lib/**/*.ex`) last to catch the rest.

  If no configuration is provided, sensible Phoenix defaults are used (see
  `default_categories/0`).
  """

  @type category :: {String.t(), String.t()}

  @default_categories [
    {"Controllers", "lib/**/controllers/**/*.ex"},
    {"LiveViews", "lib/**/live/**/*.ex"},
    {"Channels", "lib/**/channels/**/*.ex"},
    {"Components", "lib/**/components/**/*.ex"},
    {"Views", "lib/**/views/**/*.ex"},
    {"Helpers", "lib/**/helpers/**/*.ex"},
    {"Queries", "lib/**/queries/**/*.ex"},
    {"Models/Contexts",
     "lib/*/!(application|mailer|endpoint|gettext|repo|telemetry|router|release).ex"},
    {"Libraries", "lib/**/*.ex"}
  ]

  @default_test_pattern "test/**/*_test.exs"

  @doc "Returns the list of categories to analyze."
  @spec categories() :: [category()]
  def categories do
    Application.get_env(:phx_stats, :categories, @default_categories)
  end

  @doc "Returns the wildcard pattern for test files."
  @spec test_pattern() :: String.t()
  def test_pattern do
    Application.get_env(:phx_stats, :test_pattern, @default_test_pattern)
  end

  @doc "The built-in defaults — useful as a starting point for customisation."
  @spec default_categories() :: [category()]
  def default_categories, do: @default_categories
end
