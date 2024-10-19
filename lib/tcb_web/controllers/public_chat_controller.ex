defmodule TcbWeb.PublicChatController do
  alias Tcb.Chat.ChatMembers
  alias Tcb.Chat.PublicChat
  alias Tcb.Repo
  use TcbWeb, :controller
  import Ecto.Query

  @max_avatar_size_byte 3_000_000
  @allowed_avatar_content_type ["image/jpeg", "image/png", "image/webp", "image/jpg"]

  defp chat_room_name(%Plug.Upload{
         content_type: "application/json",
         filename: "blob",
         path: path
       }) do
    %{"chatRoomName" => chat_name} = File.read!(path) |> Jason.decode!()
    chat_name
  end

  defp valid_chat_image(%Plug.Upload{} = upload) do
    case upload.content_type in @allowed_avatar_content_type do
      false ->
        {:error, TcbWeb.Gettext.dgettext("avatar", "Image type not allowed")}

      true ->
        case File.stat!(upload.path) do
          %File.Stat{size: size} when size > @max_avatar_size_byte ->
            {:error, TcbWeb.Gettext.dgettext("avatar", "Image size exceeds limit")}

          _ ->
            {:ok}
        end
    end
  end

  def create(
        %Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn,
        %{"chatRoom" => %Plug.Upload{} = chat_room, "picture" => %Plug.Upload{} = picture}
      ) do
    chat_name = chat_room_name(chat_room)
    valid_image = valid_chat_image(picture)

    case valid_image do
      {:error, reason} ->
        conn |> render(:create_error, %{chat_name: "", picture: reason})

      {:ok} ->
        {:ok, data} =
          Repo.transaction(fn ->
            %Tcb.Image{id: image_id} =
              %Tcb.Image{
                name: Ecto.UUID.generate() <> Path.extname(picture.filename),
                value: File.read!(picture.path),
                default_avatar: false
              }
              |> Repo.insert!()

            %PublicChat{id: chat_id, uuid: chat_uuid} =
              %PublicChat{}
              |> PublicChat.changeset(%{
                name: chat_name,
                description: "",
                uuid: Ecto.UUID.generate(),
                created: false,
                image_id: image_id
              })
              |> Repo.insert!()

            %ChatMembers{}
            |> ChatMembers.changeset(%{chat_id: chat_id, user_id: user.id, owner: true})
            |> Repo.insert!()

            conn |> render(:create, %{uuid: chat_uuid})
          end)

        data
    end
  end

  def create(
        %Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn,
        %{"chatRoom" => chat_room}
      ) do
    chat_name = chat_room_name(chat_room)

    %PublicChat{id: chat_id, uuid: chat_uuid} =
      %PublicChat{}
      |> PublicChat.changeset(%{
        name: chat_name,
        description: "",
        uuid: Ecto.UUID.generate(),
        created: false
      })
      |> Repo.insert!()

    %ChatMembers{}
    |> ChatMembers.changeset(%{chat_id: chat_id, user_id: user.id, owner: true})
    |> Repo.insert!()

    conn |> render(:create, %{uuid: chat_uuid})
  end

  def chat_owner(
        %Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn,
        %{"uuid" => chat_uuid}
      ) do
    PublicChat.chat_owner(chat_uuid, user.id)
    |> case do
      true -> conn |> send_resp(200, "")
      false -> conn |> send_resp(400, "")
    end
  end

  def put_hashtags(
        %Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn,
        %{"uuid" => chat_uuid, "hashtag" => %{"id" => hashtag_id}}
      ) do
    from(Tcb.Hashtag,
      where: [id: ^hashtag_id],
      select: [:id]
    )
    |> Repo.one!()

    {:ok, conn} =
      Repo.transaction(fn ->
        PublicChat.chat_owner(chat_uuid, user.id)
        |> case do
          false ->
            conn |> send_resp(400, "")

          true ->
            from(PublicChat,
              where: [uuid: ^chat_uuid],
              update: [set: [hashtag_id: ^hashtag_id]]
            )
            |> Repo.update_all([])

            conn |> send_resp(200, "")
        end
      end)

    conn
  end

  def put_description(
        %Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn,
        %{"uuid" => chat_uuid, "chatRoomDescription" => chat_description}
      ) do
    PublicChat.chat_owner(chat_uuid, user.id)
    |> case do
      false ->
        conn |> send_resp(400, "")

      true ->
        from(PublicChat,
          where: [uuid: ^chat_uuid],
          update: [set: [description: ^chat_description, created: true]]
        )
        |> Repo.update_all([])

        conn |> send_resp(200, "")
    end
  end
end
