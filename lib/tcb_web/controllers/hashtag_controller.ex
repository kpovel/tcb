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

  def put_hashtags(%Plug.Conn{assigns: %{user: %Tcb.User{} = user}} = conn, %{
        "_json" => hashtag_ids
      }) do
    Repo.transaction(fn ->
      from(u in Tcb.UserHashtag,
        where: u.user_id == ^user.id
      )
      |> Repo.delete_all()

      user_hashtags =
        hashtag_ids
        |> Stream.map(fn %{"id" => id} -> id end)
        |> Enum.map(fn id -> %{user_id: user.id, hashtag_id: id} end)

      Tcb.UserHashtag
      |> Repo.insert_all(user_hashtags)
    end)

    conn |> send_resp(200, "")
  end
end
