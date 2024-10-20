defmodule TcbWeb.Plugs.ChatUser do
  alias Tcb.Repo
  import Ecto.Query
  import Plug.Conn

  def init(default), do: default

  def call(
        %Plug.Conn{
          params: %{"chat_uuid" => chat_uuid},
          assigns: %{user: %Tcb.User{} = user}
        } = conn,
        _default
      ) do
    public_chat =
      from(pc in Tcb.Chat.PublicChat,
        where: pc.uuid == ^chat_uuid
      )
      |> Repo.one!()

    conn = assign(conn, :public_chat, public_chat)

    chat_member =
      from(cm in Tcb.Chat.ChatMembers,
        where: cm.user_id == ^user.id and cm.chat_id == ^public_chat.id
      )
      |> Repo.one()

    assign(conn, :chat_member, chat_member)
  end
end
