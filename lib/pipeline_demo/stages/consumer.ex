defmodule PipelineDemo.Stages.Consumer do
  @moduledoc """
  Every one second demand for producer.
  """

  alias PipelineDemo.Stages.Producer
  use GenStage

  def start_link(pid) do
    random_id = :rand.uniform(9999)
    GenStage.start_link(__MODULE__, pid, name: consumer_alias(random_id))
  end

  def init(pid) do
    IO.puts("!!! init consumer")
    {:consumer, %{active: false}, subscribe_to: [pid]}
  end

  def handle_events(event, __from, state) do
    :timer.sleep(1000)
    IO.puts("!!! handle event #{event} pid: #{inspect(self())}")
    {:noreply, [], state}
  end

  def consumer_alias(random_id), do: :"#{__MODULE__}##{random_id}"
end
