defmodule TcbWeb.ChatRoomLive do
  alias Phoenix.LiveView
  alias Phoenix.Endpoint
  alias TcbWeb.Endpoint
  use TcbWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-dvh">
      <div id="messages" phx-update="stream" class="grow overflow-scroll">
        <%= for {dom_id, message} <- @streams.messages do %>
          <div id={dom_id}>
            <%= message.message %>
          </div>
        <% end %>
      </div>
      <.form phx-submit="send_message" for={@form} class="">
        <.input name="message" value="" class="grow w-full" />
        <button type="submit">
          submit
        </button>
      </.form>
    </div>
    """
  end

  def mount(%{"chat_uuid" => chat_uuid}, _session, socket) do
    if LiveView.connected?(socket), do: Endpoint.subscribe("chat" <> chat_uuid)

    {:ok,
     socket
     |> assign(:form, %{})
     |> assign(:chat_uuid, chat_uuid)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> stream(:messages, [
       %{id: 1, message: "foo"},
       %{id: 2, message: "bar"},
       %{id: 3, message: "baz"}
     ])}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    chat_uuid = socket.assigns.chat_uuid

    Endpoint.broadcast("chat#{chat_uuid}", "send_message", %{
      id: :rand.uniform(),
      message: message
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "send_message", payload: message}, socket) do
    {:noreply, socket |> stream_insert(:messages, message)}
  end
end
