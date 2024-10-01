defmodule Tcb.Hashtag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hashtags" do
    field :category, :string
    field :name, :string
    field :hashtag_id, :integer
    field :lang, Ecto.Enum, values: [:en, :uk]
  end

  @doc false
  def changeset(hashtag, attrs) do
    hashtag
    |> cast(attrs, [:category, :name, :lang, :hashtag_id])
    |> validate_required([:category, :name, :lang, :hashtag_id])
  end
end
