defmodule TcbWeb.AuthJSON do
  def signup(%{login: login, password: password, email: email}) do
    %{login: login, password: password, email: email}
  end

  def validate_email(%{access_token: access_token, refresh_token: refresh_token}) do
    %{jwtAccessToken: access_token, jwtRefreshToken: refresh_token}
  end
end
