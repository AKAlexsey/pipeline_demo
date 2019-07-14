use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pipeline_demo, PipelineDemoWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :pipeline_demo, PipelineDemo.Repo,
  username: "postgres",
  password: "postgres",
  database: "pipeline_demo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
