import Config

config :blitz_migration, BlitzMigration.Repo,
  database: "blitz_migration_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: "30"
