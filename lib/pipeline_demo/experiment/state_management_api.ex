defmodule PipelineDemo.Experiment.StateManagementApi do
  @moduledoc """
  Contains functions for manipulate ExperimentState
  """

  use Agent
  alias PipelineDemo.Experiment.StateAgent
  alias PipelineDemo.Stages.StageManagementApi

  # State manipulation functions
  def start(experiment_id) do
    StateAgent.set_state(experiment_id, fn
      %{is_running: true} = state ->
        state

      %{is_running: false} = state ->
        %{state | is_running: true, start_time: NaiveDateTime.utc_now()}
    end)
  end

  def stop(experiment_id) do
    StateAgent.set_state(experiment_id, fn
      %{is_running: false} = state ->
        state

      %{is_running: true, total_time: total_time, start_time: start_time} = state ->
        %{
          state
          | is_running: false,
            start_time: nil,
            total_time: total_time + NaiveDateTime.diff(NaiveDateTime.utc_now(), start_time)
        }
    end)
  end

  def reset(experiment_id) do
    %{producers: producers, consumers: consumers} = StateAgent.get_state(experiment_id)
    Enum.each(consumers, fn _producer -> StageManagementApi.terminate_consumer(experiment_id) end)
    Enum.each(producers, fn _producer -> StageManagementApi.terminate_producer(experiment_id) end)
    StateAgent.set_state(experiment_id, fn _state -> StateAgent.default_values() end)
  end

  def increase_counter(experiment_id) do
    StateAgent.set_state(experiment_id, fn
      %{is_running: false} = state ->
        state

      %{is_running: true, processed_count: processed} = state ->
        Map.put(state, :processed_count, processed + 1)
    end)
  end

  def get_state(experiment_id), do: StateAgent.get_state(experiment_id)
end
