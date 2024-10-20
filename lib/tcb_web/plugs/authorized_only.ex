defmodule TcbWeb.Plugs.AuthorizedOnly do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{req_headers: req_headers, cookies: cookies} = conn, _default) do
    token = authorization_token(req_headers, cookies)

    case Tcb.AccessToken.validate_token(token) do
      {true, access_token_id} ->
        user = Tcb.AccessToken.user_by_access_token_id(access_token_id)

        conn
        |> put_session(:user_id, user.id)
        |> put_session(:access_token, token)
        |> assign(:user, user)

      false ->
        conn |> resp(401, "") |> halt()
    end
  end

  defp authorization_token(req_headers, cookies) do
    if token = token_in_cookies(cookies) do
      token |> URI.decode()
    else
      token_in_header(req_headers)
    end
  end

  defp token_in_cookies(cookis) do
    Map.get(cookis, "jwtAccessToken")
  end

  defp token_in_header(headers) do
    headers
    |> Enum.find(fn {key, _value} -> key == "authorization" end)
    |> case do
      nil -> nil
      {_, token} -> extract_token(token)
    end
  end

  defp extract_token("Bearer " <> token), do: token
  defp extract_token(_token), do: nil
end
