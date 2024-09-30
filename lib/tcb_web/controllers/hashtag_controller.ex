defmodule TcbWeb.HashtagController do
  use TcbWeb, :controller
  alias Tcb.Repo
  import Ecto.Query

  action_fallback TcbWeb.FallbackController

  def index(%Plug.Conn{assigns: %{lang: lang}} = conn, _params) do
    hashtags =
      from(Tcb.Hashtag,
        where: [lang: ^lang],
        select: [:category, :name, :hashtag_id]
      )
      |> Repo.all()

    render(conn, :index, hashtags: hashtags)
  end
end
