defmodule PipelineDemo.Stages.Producer do
  @moduledoc """
  Generate random integer on demand
  """

  def start_link(_opts) do
    {:ok, :rand.uniform(9999)}
  end

  def terminate(_opts) do
    :ok
  end
end
