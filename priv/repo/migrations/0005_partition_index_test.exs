defmodule BlitzMigration.Repo.Migrations.PartitionIndexTest do
  use Ecto.Migration

  @disable_migration_lock true
  @disable_ddl_transaction true

  alias BlitzMigration
  alias BlitzMigration.{
    Constraint,
    Partition
  }

  def up do
    create table(:season_table) do
      add :season, :int
    end

    create table(:game_table, options: "PARTITION BY LIST (season_id)") do
      add :season_id, :int, primary_key: true
      add :field, :string
    end
    
    Constraint.create(
      :game_table, 
      "constraint_season_fkey", 
      foreign: [
        key: ["season_id"],
        ref_table: "season_table",
        ref_key: ["id"]
      ]
    )

    flush()

    Partition.create(
      :game_table, 
      [1, 2, 3], 
      &"IN (#{&1})", 
      create_default?: true
    )

    flush()

    BlitzMigration.create_partition_index(
      :game_table,
      "season_id_field_idx",
      unique: true,
      columns: ["season_id", "field"]
    )
  end

  def down do
    drop table(:game_table), mode: :cascade
    drop table(:season_table)
  end
end
