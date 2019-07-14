defmodule PipelineDemoWeb.ExperimentLive do
  use Phoenix.LiveView

  alias PipelineDemo.Experiment.{StateAgent, StateManagementApi}
  alias PipelineDemo.Stages.StageManagementApi

  @default_experiment_id 1

  def render(assigns) do
    ~L"""
    <div>
      <button phx-click="start">Start</button>
      <button phx-click="stop">Stop</button>
      <button phx-click="reset">Reset</button>
    </div>

    <div>
      <%= if length(@producers) > 0 do %>
        <%= Enum.map(@producers, fn producer -> %>
          <button style="color: red;"><%= inspect(producer) %></button>
        <% end) %>
      <% else %>
        <button style="color: green;">No producers</button>
      <% end %>
    </div>
    <div>
      <button phx-click="add_producer">Add Prod</button>
      <button phx-click="terminate_producer">Stop Prod</button>
    </div>

    <div>
      <%= if length(@consumers) > 0 do %>
        <%= Enum.map(@consumers, fn consumer -> %>
          <button style="color: red;"><%= inspect(consumer) %></button>
        <% end) %>
      <% else %>
        <button style="color: green;">No consumers</button>
      <% end %>
    </div>
    <div>
      <button phx-click="add_consumer">Add Cons</button>
      <button phx-click="terminate_consumer">Stop Cons</button>
    </div>

    <div>
      <table>
        <tr>
          <td>
            Status:
          </td>
          <td>
            <%= @status %>
          </td>
        </tr>
        <tr>
          <td>
            Processed:
          </td>
          <td>
            <%= @processed %>
          </td>
        </tr>
        <tr>
          <td>
            Time:
          </td>
          <td>
            <%= @time %>
          </td>
        </tr>
        <tr>
          <td>
            Processed:
          </td>
          <td>
            <%= @speed %>
          </td>
        </tr>
      </table>
    </div>
    """
  end

  # end%{id: id, current_user_id: user_id}, socket) do
  def mount(%{}, socket) do
    schedule_increasing()
    {:ok, set_socket_value(socket)}
  end

  def handle_info(:increase_number, socket) do
    schedule_increasing()

    StateAgent.set_state(@default_experiment_id, fn
      %{is_running: false} = state ->
        state

      %{is_running: true, processed_count: processed} = state ->
        Map.put(state, :processed_count, processed + 5)
    end)

    {:noreply, set_socket_value(socket)}
  end

  defp schedule_increasing do
    Process.send_after(self(), :increase_number, 500)
  end

  def handle_event("start", _value, socket) do
    StateManagementApi.start(@default_experiment_id)
    {:noreply, set_socket_value(socket)}
  end

  def handle_event("stop", _value, socket) do
    StateManagementApi.stop(@default_experiment_id)
    {:noreply, set_socket_value(socket)}
  end

  def handle_event("reset", _value, socket) do
    StateManagementApi.reset(@default_experiment_id)
    {:noreply, set_socket_value(socket)}
  end

  def handle_event("add_producer", _value, socket) do
    StageManagementApi.add_producer(@default_experiment_id)
    {:noreply, set_socket_value(socket)}
  end

  def handle_event("terminate_producer", _value, socket) do
    StageManagementApi.terminate_producer(@default_experiment_id)
    {:noreply, set_socket_value(socket)}
  end

  def handle_event("add_consumer", _value, socket) do
    StageManagementApi.add_consumer(@default_experiment_id)
    {:noreply, set_socket_value(socket)}
  end

  def handle_event("terminate_consumer", _value, socket) do
    StageManagementApi.terminate_consumer(@default_experiment_id)
    {:noreply, set_socket_value(socket)}
  end

  # experiment explicitly pass to function. It's identify experiment number. by default 1. Same as in supervisor.
  defp set_socket_value(socket, experiment_id \\ 1) do
    %{is_running: is_running, processed_count: processed, start_time: start_time, producers: producers, consumers: consumers} =
      StateAgent.get_state(experiment_id)

    duration = calculate_duration(NaiveDateTime.utc_now(), start_time)

    socket
    |> assign(:status, set_status_label(is_running))
    |> assign(:processed, processed)
    |> assign(:time, duration_label(duration))
    |> assign(:speed, speed_label(processed,  duration))
    |> assign(:producers, producers)
    |> assign(:consumers, consumers)
  end

  defp set_status_label(is_running), do: if(is_running, do: "RUNNING", else: "NOT_RUNNING")

  defp calculate_duration(_now, nil), do: 0
  defp calculate_duration(now, start_time), do: NaiveDateTime.diff(now, start_time)

  defp duration_label(duration), do: "#{duration} seconds"
  defp speed_label(processed, duration) do
    if(duration == 0, do: 0, else: Float.round(processed / duration, 2))
    |> (fn speed -> "#{speed} iterations per second" end).()
  end

  def handle_event(any_event, any_value, socket) do
    {:noreply, socket}
  end
end
