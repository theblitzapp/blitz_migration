defmodule BlitzMigration.ConstraintTest do

  alias BlitzMigration.Repo
  alias BlitzMigration.Repo.Migrations.{
    ConstraintTest,
    ForeignKeyConstraintTest
  }

  @valid_number 10

  use BlitzMigration.MigrationCase, 
    repos: [Repo]

  describe "create/3" do
    test "success: create unique, check and exclude constraints on table" do
      with_repo(Repo, fn repo ->
        [ConstraintTest] 
        |> get_migrations()
        |> then(&Ecto.Migrator.run(repo, &1, :up, all: true))

        repo.insert_all("constraint_test_table", [%{
          field: "unique", 
          number: @valid_number,
          value: "exclude"
        }])

        assert_raise Postgrex.Error, ~r/unique_violation/, fn ->
          repo.insert_all("constraint_test_table", [%{
            field: "unique", 
            number: @valid_number,
            value: "exclude_2"
          }])
        end

        assert_raise Postgrex.Error, ~r/check_violation/, fn ->
          repo.insert_all("constraint_test_table", [%{
            field: "check", 
            number: -1,
            value: "exclude_3"
          }])
        end

        assert_raise Postgrex.Error, ~r/exclusion_violation/, fn ->
          repo.insert_all("constraint_test_table", [%{
            field: "exclude", 
            number: @valid_number,
            value: "exclude"
          }])
        end
      end)
    end

    test "success: create foreign key constraint on table" do
      with_repo(Repo, fn repo ->
        [ForeignKeyConstraintTest] 
        |> get_migrations()
        |> then(&Ecto.Migrator.run(repo, &1, :up, all: true))

        repo.insert_all("foreign_table", [%{
          field: "field",
          field_id: 1
        }])

        repo.insert_all("constraint_table", [%{
          field: "foreign",
          ref_field: "field",
          ref_field_id: 1
        }])

        assert_raise Postgrex.Error, ~r/foreign_key_violation/, fn ->
          repo.insert_all("constraint_table", [%{
            field: "foreign", 
            ref_field: "new_field",
            ref_field_id: 2
          }])
        end
      end)
    end
  end
end
