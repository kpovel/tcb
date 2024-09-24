defmodule TcbWeb.UserController do
  alias Tcb.User
  alias Tcb.Repo
  use TcbWeb, :controller

  def onboarding_data(%Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn, _params) do
    onboarded =
      case user.onboarded do
        0 -> false
        1 -> true
      end

    conn
    |> render(:onboarding_data, %{
      data: %{
        name: user.nickname,
        userLogin: user.login,
        onboardingEnd: onboarded,
        # todo: avatar name
        image: %{name: user.avatar_id}
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
end
