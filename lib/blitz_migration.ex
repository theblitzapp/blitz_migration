defmodule BlitzMigration do
  @moduledoc """
  Documentation for `BlitzMigration`.
  """

  alias BlitzMigration.{
    Constraint, 
    Index,
    Partition
  }

  def create_partition_index(table_name, index_name, opts) do
    Partition.execute(table_name,
      &Index.create(&1, "#{&1}_#{index_name}", opts),
      &Index.create(&1, "#{&1}_#{index_name}", Keyword.drop(opts, [:concurrency]))
    )
  end

  def create_partition_constraint(table_name, constraint_name, opts), do:
    Partition.execute(table_name, &Constraint.create(&1, constraint_name, opts))
end
