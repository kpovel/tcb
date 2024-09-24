defmodule TcbWeb.UserController do
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
end
