defmodule PipelineDemoWeb.ThermostatLive do

  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %>
    <%= (1..5) |> Enum.map(fn val -> %>
      <button class="phx-alert" phx-click="inc_temperature_<%= val%>"><%= val %></button>
    <% end) %>
    <button phx-click="inc_temperature">+</button>
    <button phx-click="dec_temperature">-</button>
    """
  end

  def mount(%{}, socket) do # end%{id: id, current_user_id: user_id}, socket) do
    schedule_increasing()
    {:ok, assign(socket, :temperature, 0)}
  end

  def handle_info(:increase_number, socket) do
    schedule_increasing()
    new_temp = socket.assigns.temperature + 1
    {:noreply, assign(socket, :temperature, new_temp)}
  end

  defp schedule_increasing do
    Process.send_after(self(), :increase_number, 1000)
  end

  def handle_event("inc_temperature", value, socket) do
    new_temp = socket.assigns.temperature + 1
    {:noreply, assign(socket, :temperature, new_temp)}
  end

  def handle_event("dec_temperature", _value, socket) do
    new_temp = socket.assigns.temperature - 1
    {:noreply, assign(socket, :temperature, new_temp)}
  end

  def handle_event(any_event, any_value, socket) do
    {:noreply, socket}
  end
end
