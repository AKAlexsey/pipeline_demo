defmodule PipelineDemo.Stages.Consumer do
  @moduledoc """
  Every one second demand for producer.
  """

  # TODO rewrite demand by sending cast.
  @demand_interval 1000

  use GenStage

  def start_link(consumer_pid) do
    name = consumer_alias(:rand.uniform(9999))
    GenStage.start_link(__MODULE__, {name, consumer_pid}, name: name)
  end

  def name(identifier) do
    case identifier do
      id when is_pid(id) ->
        GenServer.call(id, :your_name)

      id when is_atom(id) ->
        GenServer.call(id, :your_name)

      id when is_integer(id) ->
        GenServer.call(consumer_alias(id), :your_name)
    end
  end

  def set_active(pid) do
    GenServer.cast(pid, :set_active)
  end

  def set_not_active(pid) do
    GenServer.cast(pid, :set_not_active)
  end

  def init({name, producer_pid}) do
    schedule_demanding()
    {:consumer, %{active: false, name: name, producer_pid: producer_pid}, subscribe_to: [producer_pid]}
  end

  def handle_events(event, __from, %{name: name} = state) do
    IO.puts("!!! handle event #{event} name: #{name}")
    {:noreply, [], state}
  end

  def consumer_alias(random_id), do: :"Consumer#{random_id}"

  def handle_call(:your_name, _from, %{name: name} = state) do
    {:reply, name, [], state}
  end

  def handle_cast(:set_active, state) do
    {:noreply, [], %{state | active: true}}
  end

  def handle_cast(:set_not_active, state) do
    {:noreply, [], %{state | active: false}}
  end

  def handle_info(:ask_producer, %{producer_pid: pid, active: active} = state) do
    IO.puts("!!! ask_producer")
    if(active, do: GenStage.ask({pid, 1}, 1))
    schedule_demanding()
    {:noreply, [], state}
  end

  defp schedule_demanding do
    Process.send_after(self(), :ask_producer, @demand_interval)
  end


end
