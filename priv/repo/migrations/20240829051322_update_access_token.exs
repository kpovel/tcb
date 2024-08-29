defmodule Tcb.Repo.Migrations.UpdateAccessToken do
  use Ecto.Migration

  def change do
    alter table("access_tokens") do
      add :refresh_token_id, references("refresh_tokens")
      remove :token
      add :token, :binary
      remove :user_id
    end

    alter table("refresh_tokens") do
      remove :token
      add :token, :binary
      remove :expired_at
      add :expired_at, :utc_datetime, null: false
    end
  end
end
