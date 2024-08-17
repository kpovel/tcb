defmodule Tcb.Repo.Migrations.User do
  use Ecto.Migration

  def change do
    create table(:image) do
      add :name, :string, null: false
      add :value, :binary, null: false
    end

    create table(:validate_email_codes) do
      add :code, :integer, null: false
      add :validated_email, :boolean, null: false, default: false
    end

    create table(:users) do
      add :login, :string, null: false
      add :nickname, :string
      add :email, :string, null: false, unique_index: true
      add :validate_email_id, references("validate_email_codes")
      add :password, :string, null: false
      add :onboarded, :boolean, null: false
      add :avatar_id, references("image")
      add :about_me, :string
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:login])

    create table(:refresh_tokens) do
      add :user_id, references(:users), null: false
      add :token, :string, null: false
      add :expired_at, :date, null: false
    end

    create table(:access_tokens) do
      add :user_id, references(:users), null: false
      add :token, :string, null: false
      add :expired_at, :utc_datetime, null: false
    end
  end
end
