defmodule TcbWeb.Plugs.Lang do
  import Plug.Conn
  @langs ["uk", "en"]

  def init(default), do: default

  def call(%Plug.Conn{query_params: %{"lang" => lang}} = conn, _default) when lang in @langs do
    Gettext.put_locale(lang)
    assign(conn, :lang, lang)
  end

  def call(conn, default) do
    Gettext.put_locale(default)
    assign(conn, :lang, default)
  end
end
