defmodule Tcb.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "image" do
    field :name, :string
    field :value, :binary
    field :default_avatar, :boolean
  end

  def changeset(image, attrs) do
    image
    |> cast(attrs, [:name, :value, :default_avatar])
    |> validate_required([:name, :value])
    |> unique_constraint(:name)
  end
end
