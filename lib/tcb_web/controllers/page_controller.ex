defmodule TcbWeb.PageController do
  alias Tcb.Usage
  alias Tcb.Repo
  use TcbWeb, :controller
  import Ecto.Query

  def home(conn, _params) do
    usage =
      from(u in Tcb.Usage,
        select: [:id, :count],
        order_by: [asc: u.count]
      )
      |> Repo.all()

    last_usage = List.last(usage) || %Usage{count: 0}
    %Usage{count: last_usage.count + 1} |> Repo.insert()

    render(conn, :home, layout: false, usage: last_usage.count)
  end
end
