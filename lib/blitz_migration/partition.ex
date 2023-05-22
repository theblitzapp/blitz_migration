defmodule BlitzMigration.Partition do
  @moduledoc """
    Helper Module for working with partitioned tables.
    It's likely that most migrations that uses this module will need these settings
    - @disable_migration_lock true
    - @disable_ddl_transaction true
    This is true when creating constraints and indexes.
  """

  import Ecto.Migration, only: [repo: 0]
  alias BlitzMigration.Common

  def get_partitions(table_name, repo \\ repo()) do
    """
    SELECT
    child.relname                   AS child
    FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
    JOIN pg_namespace nmsp_parent   ON nmsp_parent.oid  = parent.relnamespace
    JOIN pg_namespace nmsp_child    ON nmsp_child.oid   = child.relnamespace
    WHERE parent.relname='#{table_name}'
    """
    |> repo.query!()
    |> Map.get(:rows)
    |> Enum.flat_map(& &1)
  end

  def create(table_name, partition_name, value_fnc, opts) when is_binary(partition_name), 
    do: create(table_name, [partition_name], value_fnc, opts)

  def create(table_name, partition_names, value_fnc, opts) do
    if Common.table_exists?(repo(), table_name) do
      if Keyword.get(opts, :create_default?), 
        do: create_default(table_name, opts)

      Enum.map(partition_names, &create_each(&1, table_name, value_fnc, opts))
    else
      {:error, "Table to create partitions on doesn't exist"}
    end
  end

  defp create_default(table_name, opts) do
    if_not_exists = if Keyword.get(opts, :if_not_exists?), do: "IF NOT EXISTS"

    Ecto.Migration.execute(
      """
      CREATE TABLE #{if_not_exists} #{table_name}_default 
      PARTITION OF #{table_name} DEFAULT
      """,
      """
      DROP TABLE #{table_name}_default
      """
    )
  end

  defp create_each(partition_name, table_name, value_fnc, opts) do
    if_not_exists = if Keyword.get(opts, :if_not_exists?), do: "IF NOT EXISTS"

    Ecto.Migration.execute(
      """
      CREATE TABLE #{if_not_exists} #{table_name}_#{partition_name}
      PARTITION OF #{table_name}
      FOR VALUES #{value_fnc.(partition_name)}
      """,
      """
      ALTER TABLE #{table_name}
      DETACH PARTITION #{table_name}_#{partition_name};
      DROP TABLE #{table_name}_#{partition_name}
      """
    )
  end

  def execute(table_name, partition_fnc), do: execute(table_name, partition_fnc, partition_fnc)
  def execute(table_name, partition_fnc, parent_fnc) do
    table_name
    |> get_partitions()
    |> run_each(partition_fnc)
    |> case do
      :ok -> parent_fnc.(table_name)
      {:ok, _} -> parent_fnc.(table_name)
      error -> error
    end
  end

  defp run_each([], _), do: {:error, "empty partition list"}
  defp run_each(table_names, fnc) do
    Enum.reduce_while(table_names, :ok, fn 
      _, {:error, _} = error -> {:halt, error}
      table_name, _ -> {:cont, fnc.(table_name)}
    end)
  end
end
