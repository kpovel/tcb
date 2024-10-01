defmodule Tcb.Repo.Migrations.CreateHashtags do
  use Ecto.Migration

  def change do
    create table(:hashtags) do
      add :category, :string, null: false
      add :hashtag_id, :integer, null: false
      add :name, :string, null: false
      add :lang, :string, null: false
    end

    create table(:user_hashtags) do
      add :user_id, references(:users), null: false
      add :hashtag_id, references(:hashtags), null: false
    end
  end
end
