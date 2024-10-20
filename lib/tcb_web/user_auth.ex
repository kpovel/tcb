defmodule TcbWeb.UserAuth do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:assign_chat_user, params, session, socket) do
    IO.inspect(params, label: "mount params")
    IO.inspect(session, label: "mount session")
    IO.inspect(socket, label: "mount socket")
    {:cont, socket}
    # socket =
    #   assign_new(socket, :current_user, fn ->
    #     Accounts.get_user_by_session_token(user_token)
    #   end)
    #
    # if socket.assigns.current_user.confirmed_at do
    #   {:cont, socket}
    # else
    #   {:halt, redirect(socket, to: "/login")}
    # end
  end
end
