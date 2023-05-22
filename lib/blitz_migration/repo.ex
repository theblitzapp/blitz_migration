defmodule BlitzMigration.Repo do
  @moduledoc """
    This Repo is only used in test for working with BlitzMigration functions.
    Not to be accessed externally.
  """

  use Ecto.Repo,
    otp_app: :blitz_migration,
    adapter: Ecto.Adapters.Postgres
end
