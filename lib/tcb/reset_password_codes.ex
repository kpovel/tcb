defmodule Tcb.ResetPasswordCodes do
  use Ecto.Schema
  alias Ecto.Changeset
  import Ecto.Query

  schema "reset_password_codes" do
    field :code, :string
    belongs_to :user, Tcb.User
  end

  def changeset(reset_password_codes, params \\ %{}) do
    reset_password_codes
    |> Changeset.cast(params, [:code, :user_id])
    |> Changeset.validate_required([:code, :user_id])
    |> Changeset.unique_constraint(:code)
  end
end
