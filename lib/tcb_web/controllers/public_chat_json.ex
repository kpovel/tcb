defmodule TcbWeb.PublicChatJSON do
  def create(%{uuid: uuid}) do
    %{uuid: uuid}
  end

  def create_error(%{chat_name: chat_name, picture: picture}) do
    %{chatName: chat_name, picture: picture}
  end
end
