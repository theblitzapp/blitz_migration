defmodule BlitzMigration.Repo.Migrations.PartitionConstraintTest do
  use Ecto.Migration

  alias BlitzMigration
  alias BlitzMigration.Partition

  def up do
    create table(:foreign_table) do
      add :field, :string
    end

    create table("partitions", options: "PARTITION BY LIST (key)") do
      add :key, :int, primary_key: true
      add :field, :string
      add :ref_id, :id
    end

    flush()

    Partition.create(
      "partitions", 
      [1, 2, 3], 
      &"IN (#{&1})", 
      create_default?: true
    )

    flush()

    BlitzMigration.create_partition_constraint(
      :partitions,
      "partition_constraint_fid",
      foreign: [
        key: "ref_id",
        ref_table: "foreign_table",
        ref_key: "id"
      ]
    )

    BlitzMigration.create_partition_constraint(
      :partitions,
      "partition_constraint_check",
      check: "field != ''",
      not_valid: true
    )
  end

  def down do
    drop table("partitions"), mode: :cascade
    drop table(:foreign_table)
  end
end
