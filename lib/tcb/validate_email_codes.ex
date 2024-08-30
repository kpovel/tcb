defmodule Tcb.ValidateEmailCodes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "validate_email_codes" do
    field :code, :string
    field :validated_email, :boolean, default: false
  end

  def changeset(emailCodes, params \\ %{}) do
    emailCodes
    |> cast(params, [:code, :validated_email])
    |> validate_required([:code])
  end
end
