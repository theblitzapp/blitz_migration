# BlitzMigration

A library that adds onto the [Ecto.Migration](https://hexdocs.pm/ecto_sql/Ecto.Migration.html) 
set of functions to help support more complex use cases.

Currently supports the Blitz Backend Elixir team deal with partitioned tables, indexes and constraints.

This library also defines a CaseTemplate `BlitzMigration.MigrationCase` which lets you synchronously test out 
a series of migrations as if sandboxed.

## Usage

Usage is nice and simple. These functions don't follow the macro interface provided by Ecto.Migrations
and are just simple function calls that are context aware of the correct repo when used in Migration files.

```elixir
defmodule BlitzMigration.Repo.Migrations.PartitionConstraintTest do
  use Ecto.Migration

  def up do
    #create a table that will be referenced
    create table(:foreign_table) do
      add :field, :string
    end
  
    #create the parent table for partitions
    create table("partitions", options: "PARTITION BY LIST (key)") do
      add :key, :int, primary_key: true
      add :field, :string
      add :ref_id, :id
    end

    flush()

  #create partitions with BlitzMigration
    BlitzMigration.Partition.create(
      "partitions", 
      [1, 2, 3], 
      fn partition_value -> "IN (#{partition_value})" end, #sets the clause for the partition
      create_default?: true #creates a default partition for when no clauses match
    )

    flush()
  
    #create constraints on each partition
    BlitzMigration.create_partition_constraint(
      :partitions,
      "partition_constraint_fid",
      foreign: [
        key: "ref_id",
        ref_table: "foreign_table",
        ref_key: "id"
      ]
    )
  end
  
  #teardown for the specific scenario
  def down do
    drop table("partitions"), mode: :cascade
    drop table(:foreign_table)
  end
```

One requirements from the user is to be aware of the [flush/0](https://hexdocs.pm/ecto_sql/Ecto.Migration.html#flush/0) 
function and using it when changes are required to take place.

Another is that although each function provided by `BlitzMigration` is self contained with `:up` and `:down` context awareness, 
migrations are procedural and in the case of creating a parent table and its partitions in the same migration file, the `:down` will not 
work because of conflicts.

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

