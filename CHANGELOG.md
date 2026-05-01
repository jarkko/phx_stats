# Changelog

All notable changes to this project will be documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-05-01

### Added
- Initial release.
- `mix stats` task that reports lines, LOC, modules, functions, F/M and LOC/F
  per category, plus a code-to-test ratio.
- Configurable categories and test glob via `config :phx_stats, ...`.
- Sensible Phoenix defaults out of the box.
