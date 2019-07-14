defmodule PipelineDemo.Experiment.StateManagementApi do
  @moduledoc """
  Contains functions for manipulate ExperimentState
  """

  use Agent
  alias PipelineDemo.Experiment.StateAgent
  alias PipelineDemo.Stages.StageManagementApi

  #  defstruct producers: [], consumers: [], is_running: false, processed_count: 0, start_time: nil

  # State manipulation functions
  def start(experiment_id) do
    StateAgent.set_state(experiment_id, fn
      %{is_running: true} = state ->
        state

      %{is_running: false} = state ->
        state
        %{state | is_running: true, start_time: NaiveDateTime.utc_now()}
    end)
  end

  def stop(experiment_id) do
    StateAgent.set_state(experiment_id, fn
      %{is_running: false} = state ->
        state

      %{is_running: true} = state ->
        state
        %{state | is_running: false, start_time: nil}
    end)
  end

  def reset(experiment_id) do
    StateAgent.set_state(experiment_id, fn _state -> StateAgent.default_values() end)
  end
end
