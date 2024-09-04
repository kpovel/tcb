defmodule TcbWeb.TokenJSON do
  def access_token(%{access_token: token}) do
    %{jwtAccessToken: token}
  end
end
