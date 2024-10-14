defmodule TcbWeb.PublicChatController do
  alias Tcb.Chat.ChatMembers
  alias Tcb.Chat.PublicChat
  alias Tcb.Repo
  use TcbWeb, :controller

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
        %{"chatRoom" => chat_room}
      ) do
    chat_name = chat_room_name(chat_room)

    %PublicChat{} =
      chat =
      %PublicChat{}
      |> PublicChat.changeset(%{
        name: chat_name,
        description: "",
        uuid: Ecto.UUID.generate(),
        created: false
      })
      |> IO.inspect()
      |> Repo.insert!()

    %ChatMembers{}
    |> ChatMembers.changeset(%{chat_id: chat.id, user_id: user.id, owner: true})
    |> Repo.insert!()

    conn |> render(:create, %{uuid: chat.uuid})
  end

  def create(
        %Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn,
        %{"chatRoom" => %Plug.Upload{} = chat_room, "picture" => %Plug.Upload{} = picture}
      ) do
    chat_name = chat_room_name(chat_room)

    valid_upload = valid_chat_image(picture)

    case valid_upload do
      {:error, reason} -> conn |> send_resp(400, reason)
      {:ok} -> nil
    end

    # Repo.transaction(fn ->
    #   %Tcb.Image{id: image_id} =
    #     %Tcb.Image{
    #       name: Ecto.UUID.generate() <> Path.extname(image.filename),
    #       value: File.read!(image.path),
    #       default_avatar: false
    #     }
    #     |> Repo.insert!()
    #
    #   from(Tcb.User,
    #     where: [id: ^user.id],
    #     update: [set: [avatar_id: ^image_id]]
    #   )
    #   |> Repo.update_all([])
    # end)

    conn |> send_resp(400, "{}")
  end
end
