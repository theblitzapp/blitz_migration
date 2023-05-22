defmodule BlitzMigrationTest do
  
  alias BlitzMigration.{Common, Repo}
  alias BlitzMigration.Repo.Migrations.PartitionConstraintTest

  use BlitzMigration.MigrationCase, 
    repos: [Repo]

  describe "create_partition_constraint/3" do
    setup do
      tables = ~w(
        partitions 
        partitions_default 
        partitions_1
        partitions_2 
        partitions_3
      )

      %{tables: tables} 
    end
    test "success: create unique, check and exclude constraints on table", %{tables: tables} do
      with_repo(Repo, fn repo ->
        run_migrations(repo, [PartitionConstraintTest], all: true)

        for table <- tables do
          assert Common.constraint_exists?(repo, table, "partition_constraint_fid")
          assert Common.constraint_exists?(repo, table, "partition_constraint_check")
        end
      end)
    end
  end
end
