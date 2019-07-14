defmodule PipelineDemoWeb.PageController do
  use PipelineDemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
