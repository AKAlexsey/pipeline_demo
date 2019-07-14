defmodule PipelineDemo.Stages.Consumer do
  @moduledoc """
  Every one second demand for producer.
  """

  def start_link(_opts) do
    {:ok, :rand.uniform(9999)}
  end

  def terminate(_opts) do
    :ok
  end
end
