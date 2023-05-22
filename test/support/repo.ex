defmodule BlitzMigration.Repo do
  @moduledoc """
    A Test Repo.
    Create with the command:
      MIX_ENV=test mix ecto.create -r BlitzMigration.Repo
  """

  use Ecto.Repo,
    otp_app: :blitz_migration,
    adapter: Ecto.Adapters.Postgres

  def init(type, opts) do
    opts = [
      database: "blitz_migration_repo",
      username: "postgres",
      password: "postgres",
      hostname: "localhost",
      pool_size: 30
    ] ++ opts

    opts[:parent] && send(opts[:parent], {__MODULE__, type, opts})
    {:ok, opts}
  end
end
