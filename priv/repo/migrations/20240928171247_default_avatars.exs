defmodule Tcb.Repo.Migrations.DefaultAvatars do
  use Ecto.Migration

  def change do
    alter table(:image) do
      add :default_avatar, :boolean, default: false
    end

    create index(:image, [:name], unique: true)
  end
end
