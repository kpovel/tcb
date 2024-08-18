defmodule TcbWeb.Plugs.Lang do
  import Plug.Conn
  @langs ["uk", "en"]

  def init(default), do: default

  def call(%Plug.Conn{query_params: %{"lang" => lang}} = conn, _default) when lang in @langs do
    assign(conn, :lang, lang)
  end

  def call(conn, default), do: assign(conn, :lang, default)
end
