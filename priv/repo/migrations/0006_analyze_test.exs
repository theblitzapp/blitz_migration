defmodule BlitzMigration.Repo.Migrations.AnalyzeTest do
  use Ecto.Migration

  alias BlitzMigration.{Index, Analyze}

  def change do
    create table(:analyze_table) do
      add :number, :int
    end

    Index.create(
      :analyze_table, 
      "number_partial_idx", 
      columns: ["number"],
      where: "number > 0",
      tablespace: "pg_default"
    )

    Analyze.execute(:analyze_table,
      verbose: true,
      skip_locked: true,
      columns: ["number"]
    )
    
    Analyze.execute(:analyze_table)
  end
end
