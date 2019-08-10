defmodule PipelineDemo.Stages.Consumer do
  @moduledoc """
  Every one second demand for producer.
  """

  # TODO rewrite demand by sending cast.
  @demand_interval 1000
  @default_experiment_id 1

  use GenStage

  alias PipelineDemo.Experiment.StateManagementApi

  def start_link(params) do
    name = consumer_alias(:rand.uniform(9999))
    GenStage.start_link(__MODULE__, Map.put(params, :name, name), name: name)
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

  def init(%{producer_pid: producer_pid, is_running: is_running, name: name}) do
    schedule_demanding()

    {:consumer, %{active: is_running, name: name, producer_subscription: nil},
     subscribe_to: [producer_pid]}
  end

  def handle_events(_event, __from, state) do
    StateManagementApi.increase_counter(@default_experiment_id)
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

  def handle_info(
        :ask_producer,
        %{producer_subscription: producer_subscription, active: active} = state
      ) do
    if(active, do: GenStage.ask(producer_subscription, 1))
    schedule_demanding()
    {:noreply, [], state}
  end

  def handle_subscribe(:producer, _subscription_options, from, state) do
    {:manual, %{state | producer_subscription: from}}
  end

  defp schedule_demanding do
    Process.send_after(self(), :ask_producer, @demand_interval)
  end
end
