defmodule Tcb.ValidateEmailCodes do
  use Ecto.Schema

  schema "validate_email_codes" do
    field :code, :integer
    field :valited_email, :boolean, default: false
  end
end
