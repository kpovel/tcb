defmodule Tcb.AccessToken do
  use Ecto.Schema

  schema "access_tokens" do
    belongs_to :refresh_token, Tcb.RefreshToken
    field :token, :binary
    field :expired_at, :utc_datetime
  end
end
