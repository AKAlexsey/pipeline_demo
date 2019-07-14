defmodule PipelineDemoWeb.Router do
  use PipelineDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PipelineDemoWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/thermostat", ThermostatLive
    live "/experiment", ExperimentLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PipelineDemoWeb do
  #   pipe_through :api
  # end
end
