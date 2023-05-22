defmodule BlitzMigration.Common do

  def table_exists?(repo, table_name, opts \\ []) do
    schema = Keyword.get(opts, :schema, "public")

    """
    SELECT EXISTS (
       SELECT FROM information_schema.tables
       WHERE table_schema = '#{schema}'
       AND table_name = '#{table_name}'
    )
    """
    |> repo.query!()
    |> exists?()
  end

  def index_exists?(repo, table_name, partial_index_name, opts \\ []) do
    schema = Keyword.get(opts, :schema, "public")
  
    """
    SELECT EXISTS (
      SELECT FROM pg_indexes
      WHERE schemaname = '#{schema}'
      AND tablename = '#{table_name}'
      AND indexname ILIKE '%#{partial_index_name}%'
    )
    """
    |> repo.query!()
    |> exists?()
  end

  def constraint_exists?(repo, table_name, partial_constraint_name, opts \\ []) do
    schema = Keyword.get(opts, :schema, "public")

    """
    SELECT EXISTS (
      SELECT FROM pg_catalog.pg_constraint con
      INNER JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid
      INNER JOIN pg_catalog.pg_namespace nsp ON nsp.oid = connamespace
      WHERE nsp.nspname = '#{schema}'
      AND rel.relname = '#{table_name}'
      AND con.conname ILIKE '%#{partial_constraint_name}%'
    )
    """
    |> repo.query!()
    |> exists?()
  end

  defp exists?(%{rows: [[exists]]}), do: exists
end
