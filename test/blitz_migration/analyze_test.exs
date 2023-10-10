defmodule BlitzMigration.AnalyzeTest do
  alias BlitzMigration.Repo
  alias BlitzMigration.Repo.Migrations.AnalyzeTest

  use BlitzMigration.MigrationCase, 
    repos: [Repo]

  describe "execute/2" do
    test "success: run Analyze on column successfully" do
      with_repo(Repo, fn repo ->
         refute [] === run_migrations(repo, [AnalyzeTest], all: true)
      end)
    end
  end
end
