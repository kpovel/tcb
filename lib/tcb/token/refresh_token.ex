defmodule Tcb.RefreshToken do
  use Ecto.Schema

  schema "refresh_tokens" do
    belongs_to :user, Tcb.User
    field :token, :binary
    field :expired_at, :utc_datetime
  end
end
