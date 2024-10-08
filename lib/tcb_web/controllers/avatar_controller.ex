defmodule TcbWeb.AvatarController do
  use TcbWeb, :controller
  import Ecto.Query
  alias Tcb.Repo

  @max_avatar_size_byte 3_000_000
  @allowed_avatar_content_type ["image/jpeg", "image/png", "image/webp", "image/jpg"]

  def default_avatars(%Plug.Conn{} = conn, _params) do
    avatars =
      from(Tcb.Image,
        where: [default_avatar: true],
        select: [:name]
      )
      |> Repo.all()
      |> Enum.map(fn %Tcb.Image{name: name} -> name end)

    conn |> render(:default_avatars, %{data: avatars})
  end

  def avatar(%Plug.Conn{} = conn, %{"name" => name}) do
    from(Tcb.Image,
      where: [name: ^name],
      select: [:value]
    )
    |> Repo.one()
    |> case do
      nil ->
        conn |> send_resp(404, "")

      %Tcb.Image{value: value} ->
        "." <> file_extension = Path.extname(name)

        content_type =
          case file_extension do
            "svg" -> "image/svg+xml"
            extension -> "image/#{extension}"
          end

        conn
        |> put_resp_content_type(content_type)
        |> send_resp(200, value)
    end
  end

  def put_default_avatar(%Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn, %{
        "onboardingFieldStr" => default_avatar_name
      }) do
    avatar_subquery =
      from(Tcb.Image,
        where: [name: ^default_avatar_name, default_avatar: true],
        select: [:id]
      )

    from(Tcb.User,
      join: avatar in subquery(avatar_subquery),
      where: [id: ^user.id],
      update: [set: [avatar_id: avatar.id]]
    )
    |> Repo.update_all([])

    conn |> send_resp(200, "")
  end

  def put_avatar(%Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn, %{
        "image" => %Plug.Upload{} = image
      }) do
    case image.content_type in @allowed_avatar_content_type do
      false ->
        conn
        |> send_resp(
          400,
          TcbWeb.Gettext.dgettext("avatar", "Image type not allowed")
        )

      true ->
        case File.stat!(image.path) do
          %File.Stat{size: size} when size > @max_avatar_size_byte ->
            conn
            |> send_resp(
              400,
              TcbWeb.Gettext.dgettext("avatar", "Image size exceeds limit")
            )

          _ ->
            Repo.transaction(fn ->
              %Tcb.Image{id: image_id} =
                %Tcb.Image{
                  name: Ecto.UUID.generate() <> Path.extname(image.filename),
                  value: File.read!(image.path),
                  default_avatar: false
                }
                |> Repo.insert!()

              from(Tcb.User,
                where: [id: ^user.id],
                update: [set: [avatar_id: ^image_id]]
              )
              |> Repo.update_all([])
            end)

            conn |> send_resp(200, "")
        end
    end
  end
end
