defmodule TcbWeb.TokenController do
  alias Tcb.AccessToken
  alias Tcb.RefreshToken
  use TcbWeb, :controller

  def access_token(conn, %{"jwtRefreshToken" => refresh_token}) do
    case RefreshToken.validate_token(refresh_token) do
      false ->
        conn |> resp(400, "invalid token")

      {true, refresh_token_id} ->
        access_token = AccessToken.issue_access_token(refresh_token_id)

        conn |> render(:access_token, %{access_token: access_token})
    end
  end
end
