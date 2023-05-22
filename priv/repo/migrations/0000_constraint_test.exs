defmodule BlitzMigration.Repo.Migrations.ConstraintTest do
  use Ecto.Migration

  alias BlitzMigration.Constraint

  def change do
    create table(:constraint_test_table) do
      add :field, :string
      add :number, :int
      add :value, :string
    end

    Constraint.create(
      :constraint_test_table, 
      "constraint_unique_field", 
      unique: ["field"]
    )

    Constraint.create(
      :constraint_test_table, 
      "constraint_check_number", 
      check: "number > 0"
    )

    execute "CREATE EXTENSION btree_gist", "DROP EXTENSION btree_gist"

    Constraint.create(
      :constraint_test_table, 
      "constraint_exclude_value", 
      exclude: "USING gist (value WITH =)"
    )
  end
end
