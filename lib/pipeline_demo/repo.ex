defmodule PipelineDemo.Repo do
  use Ecto.Repo,
    otp_app: :pipeline_demo,
    adapter: Ecto.Adapters.Postgres
end
