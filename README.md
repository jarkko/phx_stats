# PhxStats

[![Hex.pm](https://img.shields.io/hexpm/v/phx_stats.svg)](https://hex.pm/packages/phx_stats)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/phx_stats)
[![License](https://img.shields.io/hexpm/l/phx_stats.svg)](https://github.com/jarkko/phx_stats/blob/main/LICENSE)

A Rails-style `mix stats` task for Elixir and Phoenix projects.

PhxStats reports lines of code, modules, functions, and the code-to-test ratio
of your project, broken down by configurable categories — controllers,
LiveViews, contexts, components, and so on.

```text
+----------------------+--------+--------+---------+---------+-----+-------+
| Name                 |  Lines |    LOC | Modules |   Funcs | F/M | LOC/F |
+----------------------+--------+--------+---------+---------+-----+-------+
| Controllers          |   1234 |    890 |      12 |     123 |  10 |     7 |
| LiveViews            |   2345 |   1789 |      23 |     234 |  10 |     7 |
| Components           |    456 |    320 |       8 |      40 |   5 |     8 |
| Models/Contexts      |   1100 |    800 |      15 |     110 |   7 |     7 |
+----------------------+--------+--------+---------+---------+-----+-------+
| Total                |   5135 |   3799 |      58 |     507 |   8 |     7 |
+----------------------+--------+--------+---------+---------+-----+-------+
  Code LOC: 3799     Test LOC: 1900     Code to Test Ratio: 1:0.5
```

## Installation

Add `phx_stats` as a dev-only dependency in `mix.exs`:

```elixir
def deps do
  [
    {:phx_stats, "~> 0.1", only: :dev, runtime: false}
  ]
end
```

Then:

```bash
$ mix deps.get
$ mix stats
```

## Configuration

Out of the box, PhxStats ships with sensible defaults for Phoenix projects.
You can override them in `config/config.exs`:

```elixir
config :phx_stats,
  categories: [
    {"Controllers",    "lib/**/controllers/**/*.ex"},
    {"LiveViews",      "lib/**/live/**/*.ex"},
    {"Components",     "lib/**/components/**/*.ex"},
    {"Contexts",       "lib/my_app/*.ex"},
    {"Workers",        "lib/my_app/workers/**/*.ex"}
  ],
  test_pattern: "test/**/*_test.exs"
```

Each category is a `{name, glob}` pair. Globs use `Path.wildcard/1` syntax,
including brace expansion (`{a,b}`) and negation (`!(...)`).

Tip: a final `{"Libraries", "lib/**/*.ex"}` row captures everything not yet
matched, so the **Total** counts every file once. (Files matched by multiple
categories are counted in each — this matches Rails' `rake stats` behaviour.)

## How it works

For each category, PhxStats expands the glob and counts:

- **Lines** — total lines in the file.
- **LOC** — non-blank, non-comment lines.
- **Modules** — `defmodule` declarations.
- **Funcs** — `def`, `defp`, `defmacro`, `defmacrop` declarations.
- **F/M** — functions per module (integer division).
- **LOC/F** — LOC per function (integer division).

The summary line shows the code LOC, test LOC, and their ratio. Test files
are matched separately by `:test_pattern` and **not** included in the total.

## Limitations

PhxStats is intentionally simple: it relies on regular expressions over source
text rather than parsing Elixir's AST. This keeps it fast and dependency-free,
but a function defined inside a string literal or heredoc could in principle be
counted. In practice this is not a meaningful source of error for normal code.

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/jarkko/phx_stats). Run `mix test` and
`mix format --check-formatted` before opening a PR.

## License

MIT — see [LICENSE](LICENSE).
