defmodule PhxStats.ConfigTest do
  use ExUnit.Case

  alias PhxStats.Config

  setup do
    on_exit(fn ->
      Application.delete_env(:phx_stats, :categories)
      Application.delete_env(:phx_stats, :test_pattern)
    end)
  end

  test "falls back to default categories when unset" do
    Application.delete_env(:phx_stats, :categories)
    assert Config.categories() == Config.default_categories()
  end

  test "uses configured categories when set" do
    Application.put_env(:phx_stats, :categories, [{"X", "lib/x.ex"}])
    assert Config.categories() == [{"X", "lib/x.ex"}]
  end

  test "test_pattern defaults to a sensible glob and is overridable" do
    Application.delete_env(:phx_stats, :test_pattern)
    assert Config.test_pattern() == "test/**/*_test.exs"

    Application.put_env(:phx_stats, :test_pattern, "spec/**/*_spec.exs")
    assert Config.test_pattern() == "spec/**/*_spec.exs"
  end
end
