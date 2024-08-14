defmodule Tcb.AccessToken do
  use Ecto.Schema

  schema "access_tokens" do
    belongs_to :user_id, Tcb.User
    field :token, :string
    field :expired_at, :date
  end
end
