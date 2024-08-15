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

  def valitate_email(email) when not is_binary(email), do: false

  def valitate_email(email) do
    email
    |> String.match?(
      ~r/^(?!\.)(?!.*\.\.)([A-Z0-9_'+\-\.]*)[A-Z0-9_+-]@([A-Z0-9][A-Z0-9\-]*\.)+[A-Z]{2,}$/i
    )
  end
end
