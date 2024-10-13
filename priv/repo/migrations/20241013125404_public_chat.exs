defmodule Tcb.Repo.Migrations.PublicChat do
  use Ecto.Migration

  def change do
    create table(:public_chats) do
      add :name, :string, null: false
      add :description, :string, null: false
      add :uuid, :string, null: false
      add :image_id, references(:image)
      add :hashtag_id, references(:hashtags)
      add :created, :boolean, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:chat_members) do
      add :chat_id, references(:public_chats), null: false
      add :user_id, references(:users), null: false
      add :owner, :boolean, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:chat_messages) do
      add :chat_member_id, references(:chat_members), null: false
      add :message, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
