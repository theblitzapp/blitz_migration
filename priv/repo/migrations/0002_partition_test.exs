defmodule BlitzMigration.Repo.Migrations.PartitionTest do
  use Ecto.Migration

  @disable_migration_lock true
  @disable_ddl_transaction true

  alias BlitzMigration.Partition

  def up do
    create table("partitions", options: "PARTITION BY LIST (key)") do
      add :key, :string, primary_key: true
      add :field, :string
      add :count, :int
    end

    flush()

    Partition.create(
      "partitions", 
      ["blue", "red", "yellow"], 
      &"IN ('#{&1}')", 
      create_default?: true
    )

    flush()

    Partition.execute(
      "partitions",
      &execute(
        """
        CREATE INDEX CONCURRENTLY #{&1}_field
        ON #{&1} (field)
        """
      ),
      &execute(
        """
        CREATE INDEX #{&1}_field
        ON #{&1} (field)
        """
      )
    )
  end

  def down do
    drop table("partitions"), mode: :cascade
  end
end
