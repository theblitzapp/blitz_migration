defmodule BlitzMigrationTest do
  
  alias BlitzMigration.{Common, Repo}
  alias BlitzMigration.Repo.Migrations.{
    PartitionConstraintTest,
    PartitionIndexTest
  }

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

  describe "create_partition_index/3" do
    setup do
      tables = ~w(
        game_table 
        game_table_default 
        game_table_1
        game_table_2 
        game_table_3
      )

      %{tables: tables} 
    end
    test "success: create unique, index on partitions and parent", %{tables: tables} do
      with_repo(Repo, fn repo ->
        run_migrations(repo, [PartitionIndexTest], all: true)

        for table <- tables do
          assert Common.index_exists?(repo, table, "#{table}_season_id_field_idx")
        end
      end)
    end
    
  end
end
