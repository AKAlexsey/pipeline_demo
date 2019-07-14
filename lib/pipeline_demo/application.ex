defmodule PipelineDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias PipelineDemo.Experiment.StateAgent

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      PipelineDemo.Repo,
      # Start the endpoint when the application starts
      PipelineDemoWeb.Endpoint,
      # Start agent for store state between sessions.
      {StateAgent, %{initial_state: %{}, id: 1}}
      # Starts a worker by calling: PipelineDemo.Worker.start_link(arg)
      # {PipelineDemo.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PipelineDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PipelineDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
