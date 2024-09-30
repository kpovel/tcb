defmodule TcbWeb.HashtagController do
  use TcbWeb, :controller
  alias Tcb.Repo

  action_fallback TcbWeb.FallbackController

  def index(conn, _params) do
    hashtags = Tcb.Hashtag |> Repo.all()
    render(conn, :index, hashtags: hashtags)
  end
end
