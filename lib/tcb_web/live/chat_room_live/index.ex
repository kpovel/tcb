defmodule TcbWeb.ChatRoomLive do
  alias Tcb.Repo
  alias Tcb.Chat.ChatMessages
  alias Phoenix.LiveView
  alias Phoenix.Endpoint
  alias TcbWeb.Endpoint
  use TcbWeb, :live_view
  import Ecto.Query

  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-dvh">
      <%= if Enum.count(@streams.messages) == 0 do %>
        <div>
          no messages here
        </div>
      <% end %>
      <div
        id="messages"
        phx-update="stream"
        class="grow overflow-scroll"
        phx-viewport-top="load_previous_messages"
      >
        <%= for {dom_id, message} <- @streams.messages do %>
          <div id={dom_id}>
            <%= message.message %>
          </div>
        <% end %>
      </div>
      <.form phx-submit="send_message" phx-change="change" for={@form} class="">
        <.input id="message-input" name="message" value={@form[:message]} class="grow w-full" />
        <button type="submit">
          submit
        </button>
      </.form>
    </div>
    """
  end

  def mount(%{"chat_uuid" => chat_uuid} = _params, %{"user_id" => user_id} = _session, socket) do
    if LiveView.connected?(socket), do: Endpoint.subscribe("chat" <> chat_uuid)

    public_chat =
      from(pc in Tcb.Chat.PublicChat,
        where: pc.uuid == ^chat_uuid
      )
      |> Repo.one!()

    # todo: if null ask to join the chat
    chat_member =
      from(cm in Tcb.Chat.ChatMembers,
        where: cm.user_id == ^user_id and cm.chat_id == ^public_chat.id
      )
      |> Repo.one()

    {:ok,
     socket
     |> assign(:form, %{message: ""})
     |> assign(:public_chat, public_chat)
     |> assign(:chat_member, chat_member)
     |> assign(:chat_uuid, chat_uuid)}
  end

  def handle_params(
        _params,
        _uri,
        %{assigns: %{public_chat: %Tcb.Chat.PublicChat{} = chat}} = socket
      ) do
    messages =
      from(ChatMessages,
        where: [public_chat_id: ^chat.id],
        select: [:id, :message, :chat_member_id, :inserted_at],
        order_by: [desc: :id],
        limit: 25
      )
      |> Repo.all()
      |> Enum.reverse()

    {:noreply,
     socket
     |> stream(:messages, messages)}
  end

  def handle_event("change", %{"message" => message}, socket) do
    {:noreply,
     socket
     |> Phoenix.Component.update(:form, fn form ->
       Map.put(form, :message, message)
     end)}
  end

  def handle_event(
        "send_message",
        %{"message" => message},
        %{assigns: %{chat_member: %Tcb.Chat.ChatMembers{id: chat_member_id, chat_id: chat_id}}} =
          socket
      ) do
    chat_uuid = socket.assigns.chat_uuid

    message =
      %ChatMessages{
        chat_member_id: chat_member_id,
        public_chat_id: chat_id,
        message: message
      }
      |> Repo.insert!()

    Endpoint.broadcast("chat#{chat_uuid}", "send_message", message)

    {:noreply,
     socket
     |> assign(:form, %{message: ""})}
  end

  def handle_info(%{event: "send_message", payload: message}, socket) do
    {:noreply, socket |> stream_insert(:messages, message)}
  end
end
