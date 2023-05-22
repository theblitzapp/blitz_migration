defmodule BlitzMigration.Repo.Migrations.ForeignKeyConstraintTest do
  use Ecto.Migration

  alias BlitzMigration.Constraint

  def change do
    create table(:constraint_table) do
      add :field, :string
      add :ref_field, :string
      add :ref_field_id, :int
    end

    create table(:foreign_table) do
      add :field, :string
      add :field_id, :int
    end

    Constraint.create(
      :foreign_table, 
      "constraint_unique_key", 
      unique: ["field", "field_id"]
    )

    Constraint.create(
      :constraint_table, 
      "constraint_field_fkey", 
      foreign: [
        key: ["ref_field", "ref_field_id"],
        ref_table: "foreign_table",
        ref_key: ["field", "field_id"]
      ]
    )
  end
end
