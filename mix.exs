defmodule BlitzMigration.MixProject do
  use Mix.Project

  def project do
    [
      app: :blitz_migration,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:nimble_options, "~> 1.0"}
    ]
  end

  defp package do
    [
      maintainers: ["Thomas Furland", "theblitzapp"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/theblitzapp/blitz_migration"},
      files: ~w(mix.exs README.md CHANGELOG.md LICENSE lib)
    ]
  end
end
