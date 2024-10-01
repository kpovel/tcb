defmodule TcbWeb.Plugs.AuthorizedOnly do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{req_headers: req_headers} = conn, _default) do
    case authorization_token(req_headers) do
      nil ->
        conn |> resp(401, "") |> halt()

      token ->
        case Tcb.AccessToken.validate_token(token) do
          {true, access_token_id} ->
            user = Tcb.AccessToken.user_by_access_token_id(access_token_id)
            assign(conn, :user, user)

          false ->
            conn |> resp(401, "") |> halt()
        end
    end
  end

  defp authorization_token(req_headers) do
    auth_header =
      req_headers
      |> Enum.find(fn {key, _value} -> key == "authorization" end)

    case auth_header do
      nil -> nil
      {_, token} -> extract_token(token)
    end
  end

  defp extract_token("Bearer " <> token), do: token
  defp extract_token(_token), do: nil
end
