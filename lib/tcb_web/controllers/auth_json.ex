defmodule TcbWeb.AuthJSON do
  def signup(%{login: login, password: password, email: email}) do
    %{login: login, password: password, email: email}
  end
end
