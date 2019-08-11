defmodule PipelineDemo.Stages.Producer do
  @moduledoc """
  Generate random integer on demand
  """

  use GenStage

  def start_link([]) do
    name = producer_alias(:rand.uniform(9999))
    GenStage.start_link(__MODULE__, name, name: name)
  end

  def init(name) do
    {:producer, %{name: name}, dispatcher: GenStage.DemandDispatcher}
  end

  def handle_demand(demand, state) do
    {:noreply, [:rand.uniform(9999)], state}
  end

  def producer_alias(number), do: :"Producer##{number}"

  def handle_call(identifier) do
    case identifier do
      id when is_pid(id) ->
        GenServer.call(id, :your_name)

      id when is_atom(id) ->
        GenServer.call(id, :your_name)

      id when is_integer(id) ->
        GenServer.call(producer_alias(id), :your_name)
    end
  end

  def name(atom) do
    GenServer.call(atom, :your_name)
  end

  def handle_call(:your_name, _from, %{name: name} = state) do
    {:reply, name, [], state}
  end

  def handle_subscribe(prod, opts, from, state) do
    {:automatic, state}
  end
end
