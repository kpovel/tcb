defmodule Tcb.Repo.Migrations.Usage do
  use Ecto.Migration

  def change do
    create table(:usage) do
      add :count, :integer, null: false, default: 0
    end
  end
end
