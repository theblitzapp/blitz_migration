defmodule BlitzMigration.MigrationCase do
  @moduledoc """
    This Migration case is used to make it possible to test functions that will be used as Migration Helpers.
    The using test module will automatically have the :migration moduletag which should always be excluded.
    Async Testing is not supported and ideally the repos used are specifically for testing only.
    One assumption is that the repo adapters are not using Sandbox. This is because migrations require 2 connections.
    This is not possible for the Sandbox adapter.
  """
  use ExUnit.CaseTemplate

  using raw_opts do
    quote do
      import Ecto.Query
      import BlitzMigration.MigrationCase, only: [start_repo: 2, with_repo: 2, compile_migrations: 1, get_migration_module: 2]

      @moduletag :migration

      opts = unquote(raw_opts)
      @repos Keyword.fetch!(opts, :repos)
      @otp_app Keyword.get(opts, :otp_app, :blitz_pg)
      @clean_up? Keyword.get(opts, :clean_up?, :true)

      # Used because we compile the migration files
      setup_all do
        Code.put_compiler_option(:ignore_module_conflict, true)
        on_exit(fn -> Code.put_compiler_option(:ignore_module_conflict, false) end)
      end

      setup do
        # useful when wanting to see migration results from dbms
        if @clean_up? do
          on_exit(fn -> 
            @repos
            |> tap(&Enum.each(&1, fn repo -> start_repo(repo, @otp_app) end))
            |> Enum.each(&with_repo(&1, fn repo -> 
                Ecto.Migrator.run(repo, :down, all: true) 
              end))
          end)
        end

        Enum.each(@repos, &start_repo(&1, @otp_app))
      end

      def get_migrations(modules) do
        migrations = Enum.flat_map(@repos, &compile_migrations/1)
        Enum.map(modules, &get_migration_module(migrations, &1))
      end
    end
  end

  def start_repo(repo, app) do
    app
    |> Application.get_env(repo)
    |> repo.start_link()
  end

  def with_repo(repo, fnc) do
    Ecto.Migrator.with_repo(repo, fnc)
    repo.stop()
  end

  def compile_migrations(repo) do
    migration_info =
      repo
      |> Ecto.Migrator.migrations_path()
      |> then(&Path.join([&1, "**", "*.exs"]))
      |> Path.wildcard()
      |> Stream.map(&extract_migration_info/1)
      |> Enum.reject(&is_nil/1)

    migration_info
    |> Stream.map(&elem(&1, 2))
    |> Enum.each(&Code.compile_file/1)

    migration_info
  end

  defp extract_migration_info(file) do
    file
    |> Path.basename()
    |> Path.rootname()
    |> Integer.parse()
    |> case do
      {int, "_" <> name} when 
        is_integer(int) and is_binary(name) -> {int, name, file}
      _ -> nil
    end
  end

  def get_migration_module(migrations, module) do
    module_name = 
      module
      |> Module.split()
      |> List.last()

    case Enum.find(migrations, &match_migration_name(&1, module_name)) do
      {int, _, _} -> {int, module} 
      _ -> raise "no migration file found"
    end
  end

  defp match_migration_name({_, name, _}, match), do:
    Macro.camelize(name) === match
end
