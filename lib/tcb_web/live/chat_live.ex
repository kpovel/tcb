defmodule TcbWeb.ChatLive do
  alias Phoenix.LiveView
  alias Phoenix.Endpoint
  alias TcbWeb.Endpoint
  use TcbWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="">
      <div>
        Count: <%= @count %>
      </div>
      <button phx-click="add">
        add
      </button>
      <button phx-click="remove">
        remove
      </button>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # todo: personal chat list view for the user
    if LiveView.connected?(socket), do: Endpoint.subscribe("room")
    {:ok, socket |> assign(:count, 0)}
  end

  def handle_event("add", _value, socket) do
    count = socket.assigns.count + 1
    Endpoint.broadcast("room", "update_count", %{count: count})

    {:noreply, socket |> assign(:count, count)}
  end

  def handle_event("remove", _value, socket) do
    count = socket.assigns.count - 1
    Endpoint.broadcast("room", "update_count", %{count: count})

    {:noreply, socket |> assign(:count, count)}
  end

  def handle_info(%{event: "update_count", payload: %{count: count}}, socket) do
    {:noreply, assign(socket, :count, count)}
  end
end
