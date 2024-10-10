defmodule Tcb.Repo.Migrations.ResetPasswordCodes do
  use Ecto.Migration

  def change do
    create table(:reset_password_codes) do
      add :user_id, references(:users)
      add :code, :string, null: false
    end
  end
end
