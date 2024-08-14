defmodule Tcb.User do
  use Ecto.Schema

  schema "users" do
    field :login, :string
    field :nickname, :string
    field :email, :string
    field :password, :string
    field :onboarded, :boolean
    field :about_me, :string
    belongs_to :validate_email, Tcb.ValidateEmailCodes
    belongs_to :avatar_id, Tcb.Image
  end
end
