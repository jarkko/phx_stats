defmodule PhxStats.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/jarkko/phx_stats"

  def project do
    [
      app: :phx_stats,
      version: @version,
      elixir: "~> 1.14",
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "PhxStats",
      source_url: @source_url,
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A Rails-style `mix stats` task for Elixir and Phoenix projects. " <>
      "Reports lines of code, modules, functions, and code-to-test ratio, " <>
      "broken down by configurable categories."
  end

  defp package do
    [
      maintainers: ["Jarkko Laine"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
