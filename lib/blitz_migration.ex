defmodule BlitzMigration do
  @moduledoc """
  Documentation for `BlitzMigration`.
  """

  alias BlitzMigration.{Constraint, Partition}

  def create_partition_constraint(table_name, constraint_name, opts), do:
    Partition.execute(table_name, &Constraint.create(&1, constraint_name, opts))
end
