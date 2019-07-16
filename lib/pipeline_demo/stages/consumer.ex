defmodule PipelineDemo.Stages.Consumer do
  @moduledoc """
  Every one second demand for producer.
  """

  use GenStage

  def start_link(consumer_pid) do
    name = consumer_alias(:rand.uniform(9999))
    GenStage.start_link(__MODULE__, {name, consumer_pid}, name: name)
  end

  def init({name, consumer_pid}) do
    {:consumer, %{active: false, name: name}, subscribe_to: [consumer_pid]}
  end

  def handle_events(event, __from, %{name: name} = state) do
    :timer.sleep(1000)
    IO.puts("!!! handle event #{event} name: #{name}")
    {:noreply, [], state}
  end

  def consumer_alias(random_id), do: :"Consumer#{random_id}"

  def handle_call(identifier) do
    case identifier do
      id when is_pid(id) ->
        GenServer.call(id, :your_name)

      id when is_atom(id) ->
        GenServer.call(id, :your_name)

      id when is_integer(id) ->
        GenServer.call(consumer_alias(id), :your_name)
    end
  end

  def name(atom) do
    GenServer.call(atom, :your_name)
  end

  def handle_call(:your_name, _from, %{name: name} = state) do
    {:reply, name, [], state}
  end
end
