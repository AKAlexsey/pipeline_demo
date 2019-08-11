defmodule PipelineDemo.Experiment.StateAgent do
  @moduledoc """
  Contains logic for storing data between sessions.
  It's state represent state of the experiment with GenStages.
  """

  use Agent

  def default_values,
    do: %{
      producers: [],
      consumers: [],
      is_running: false,
      processed_count: 0,
      start_time: nil,
      total_time: 0
    }

  def start_link(%{initial_state: initial_state, id: id}) do
    Agent.start_link(fn -> Map.merge(default_values(), initial_state) end, name: agent_alias(id))
  end

  def get_state(id) do
    case GenServer.whereis(agent_alias(id)) do
      nil ->
        %{}

      _ ->
        Agent.get(agent_alias(id), fn state -> state end)
    end
  end

  def set_state(id, function) do
    Agent.update(agent_alias(id), function)
  end

  defp agent_alias(id) do
    :"#{__MODULE__}##{id}"
  end
end
