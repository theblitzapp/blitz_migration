# BlitzMigration

A library that adds onto the [Ecto.Migration](https://hexdocs.pm/ecto_sql/Ecto.Migration.html) 
set of functions to help support more complex use cases.

Currently supports the Blitz Backend Elixir team deal with partitioned tables, indexes and constraints.

This library also defines a CaseTemplate `BlitzMigration.MigrationCase` which lets you synchronously test out 
a series of migrations as if sandboxed.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `blitz_migration` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:blitz_migration, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/blitz_migration>.

