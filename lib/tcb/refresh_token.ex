defmodule Tcb.RefreshToken do
  use Ecto.Schema

  schema "refresh_tokens" do
    belongs_to :user_id, Tcb.User
    field :token, :string
    field :expired_at, :date
  end
end
