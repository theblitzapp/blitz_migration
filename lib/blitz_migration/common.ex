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
      WHERE tablename = '#{table_name}'
      AND schemaname = '#{schema}'
      AND indexname ILIKE '%#{partial_index_name}%'
    )
    """
    |> repo.query!()
    |> exists?()
  end

  defp exists?(%{rows: [[exists]]}), do: exists
end
