defmodule TcbWeb.UserController do
  use TcbWeb, :controller
  alias Tcb.User
  alias Tcb.Repo
  import Ecto.Query

  def onboarding_data(%Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn, _params) do
    onboarded =
      case user.onboarded do
        0 -> false
        1 -> true
      end

    avatar_name =
      from(Tcb.Image,
        where: [id: ^user.avatar_id],
        select: [:name]
      )
      |> Repo.one()
      |> case do
        nil -> nil
        %Tcb.Image{name: name} -> name
      end

    conn
    |> render(:onboarding_data, %{
      data: %{
        name: user.nickname,
        userLogin: user.login,
        onboardingEnd: onboarded,
        image: %{name: avatar_name}
      }
    })
  end

  def put_user_about(
        %Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn,
        %{"onboardingFieldStr" => about_me}
      ) do
    case String.length(about_me) do
      len when len > 300 ->
        conn
        |> render(:about_too_long, %{
          fieldMessage: TcbWeb.Gettext.dgettext("onboarding", "About me field is too long")
        })

      _ ->
        user |> User.changeset(%{about_me: about_me}) |> Repo.update!()
        conn |> send_resp(200, "")
    end
  end

  def end_onboarding(%Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn, %{
        "onboardingEnd" => true
      }) do
    user |> User.changeset(%{onboarded: true}) |> Repo.update!()

    conn |> send_resp(200, "")
  end
end
