defmodule PipelineDemo.Stages.Producer do
  @moduledoc """
  Generate random integer on demand
  """

  use GenStage

  def start_link([]) do
    rand_id = :rand.uniform(9999)
    GenStage.start_link(__MODULE__, [], name: producer_alias(rand_id))
  end

  def init(_opts) do
    {:producer, [], dispatcher: GenStage.DemandDispatcher}
  end

  def handle_demand(_demand, state) do
    {:noreply, :rand.uniform(9999), state}
  end

  def producer_alias(number), do: :"Producer##{number}"
end
