defmodule BlitzMigration.PartitionTest do
  
  alias BlitzMigration.{Common, Partition, Repo}
  alias BlitzMigration.Repo.Migrations.PartitionTest

  use BlitzMigration.MigrationCase, 
    repos: [Repo]

  @table_list ~w(
    partitions 
    partitions_default 
    partitions_blue 
    partitions_red 
    partitions_yellow
  )

  describe "create/4" do
    test "success: creates partition tables off of a parent table" do
      with_repo(Repo, fn repo ->
        run_migrations(repo, [PartitionTest], all: true)

        partition_set = 
          "partitions"
          |> Partition.get_partitions(repo) 
          |> MapSet.new()

        assert MapSet.equal?(partition_set,
          @table_list
          |> Enum.take(-4)
          |> MapSet.new()
        )
      end)
    end
  end

  describe "execute/2" do
    test "success: executes changes on partition tables and parent table" do
      with_repo(Repo, fn repo ->
        run_migrations(repo, [PartitionTest], all: true)

        for table_name <- @table_list do
          assert Common.index_exists?(repo, table_name, "#{table_name}_field")
        end
      end)
    end
  end
end
