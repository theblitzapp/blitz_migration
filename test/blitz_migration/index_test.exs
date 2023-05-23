defmodule BlitzMigration.IndexTest do
  alias BlitzMigration.{Common, Repo}
  alias BlitzMigration.Repo.Migrations.IndexTest

  use BlitzMigration.MigrationCase, 
    repos: [Repo]

  describe "index/3" do
    test "success: creates index successfully" do
      with_repo(Repo, fn repo ->
      run_migrations(repo, [IndexTest], all: true)
        assert Common.index_exists?(repo, :index_table, "field_idx")
        assert Common.index_exists?(repo, :index_table, "number_partial_idx")
      end)
    end
  end
end
