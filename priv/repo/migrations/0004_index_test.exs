defmodule BlitzMigration.Repo.Migrations.IndexTest do
  use Ecto.Migration

  alias BlitzMigration.Index

  def change do
    create table(:index_table) do
      add :field, :string
      add :number, :int
      add :value, :string
    end

    Index.create(
      :index_table, 
      "field_idx", 
      unique: true,
      concurrently: false,
      if_not_exists: true,
      using: "btree",
      columns: ["field NULLS FIRST"],
      include: ["value", "number"],
      with: "fillfactor = 70"
    )

    Index.create(
      :index_table, 
      "number_partial_idx", 
      columns: ["number"],
      where: "number > 0",
      tablespace: "pg_default"
    )
  end
end
