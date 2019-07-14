defmodule PipelineDemo.Stages.StageManagementApi do
  @moduledoc """
  Contains for spawning and terminating producer and consumer stages.
  """

  @max_producers_count 1
  @max_consumers_count 5

  alias PipelineDemo.Experiment.StateAgent
  alias PipelineDemo.Stages.{Consumer, Producer}

  @spec add_producer(integer) :: :ok | {:error, :maximum_producers_achieved}
  def add_producer(experiment_id) do
    with %{producers: producers} <- StateAgent.get_state(experiment_id),
         false <- length(producers) >= @max_producers_count,
         {:ok, pid} <- Producer.start_link([]),
         new_producers <- producers ++ [pid],
         :ok <- StateAgent.set_state(experiment_id, fn old_state -> %{old_state | producers: new_producers} end) do
      :ok
    else
      true -> {:error, :maximum_producers_achieved}
      %{} -> {:error, :no_such_experiment}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec terminate_producer(integer) :: :ok
  def terminate_producer(experiment_id) do
    with %{producers: producers} <- StateAgent.get_state(experiment_id),
         true <- length(producers) > 0,
         [removed_producer | left_producers] = producers,
         :ok <- Producer.terminate(removed_producer),
         :ok <- StateAgent.set_state(experiment_id, fn old_state -> %{old_state | producers: left_producers} end) do
      :ok
    else
      false -> {:error, :there_is_no_producers}
      %{} -> {:error, :no_such_experiment}
     {:error, reason} -> {:error, reason}
    end
  end

  @spec add_consumer(integer) :: :ok | {:error, :maximum_consumers_achieved}
  def add_consumer(experiment_id) do
    with %{consumers: consumers} <- StateAgent.get_state(experiment_id),
         false <- length(consumers) >= @max_consumers_count,
         {:ok, pid} <- Consumer.start_link([]),
         new_consumers <- consumers ++ [pid],
         :ok <- StateAgent.set_state(experiment_id, fn old_state -> %{old_state | consumers: new_consumers} end) do
      :ok
    else
      true -> {:error, :maximum_consumers_achieved}
      %{} -> {:error, :no_such_experiment}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec terminate_consumer(integer) :: :ok
  def terminate_consumer(experiment_id) do
    with %{consumers: consumers} <- StateAgent.get_state(experiment_id),
         true <- length(consumers) > 0,
         [removed_consumer | left_consumers] = consumers,
         :ok <- Consumer.terminate(removed_consumer),
         :ok <- StateAgent.set_state(experiment_id, fn old_state -> %{old_state | consumers: left_consumers} end) do
      :ok
    else
      false -> {:error, :there_is_no_consumers}
      %{} -> {:error, :no_such_experiment}
     {:error, reason} -> {:error, reason}
    end
  end
end
