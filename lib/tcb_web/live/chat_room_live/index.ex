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

  def mount(%{"chat_uuid" => chat_uuid} = params, session, socket) do
    if LiveView.connected?(socket), do: Endpoint.subscribe("chat" <> chat_uuid)
    # IO.inspect(params, structs: false, label: "params!!!!!!!!!")
    # IO.inspect(socket, structs: false, label: "mount socket")
    # IO.inspect(session, structs: false, label: "session how")

    {:ok,
     socket
     |> assign(:form, %{})
     |> assign(:form, %{})
     |> assign(:chat_uuid, chat_uuid)}
  end

  def handle_params(_params, _uri, socket) do
    # IO.inspect(socket, label: "socket!!!!!!!!")

    # public_chat =
    #   from(pc in Tcb.Chat.PublicChat,
    #     where: pc.uuid == ^chat_uuid
    #   )
    #   |> Repo.one!()
    #
    #
    # chat_member =
    #   from(cm in Tcb.Chat.ChatMembers,
    #     where: cm.user_id == ^user.id and cm.chat_id == ^public_chat.id
    #   )
    #   |> Repo.one()
    #
    #
    # from(ChatMessages,
    #   where: [public_chat_id: ^socket.public_chat.id],
    #   select: [:id],
    #   limit: 25
    # )
    # |> Repo.all()
    # |> IO.inspect(label: "chat messages")

    # todo: last 25 messages
    {:noreply,
     socket
     # |> assign(:public_chat, public_chat)
     # |> assign(:chat_member, chat_member)
     |> stream(:messages, [
       %{id: 1, message: "foo"},
       %{id: 2, message: "bar"},
       %{id: 3, message: "baz"}
     ])}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    chat_uuid = socket.assigns.chat_uuid

    %ChatMessages{
      chat_member: 69,
      message: message
    }
    |> Repo.insert!()

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
