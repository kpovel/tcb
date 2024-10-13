defmodule Tcb.Chat.PublicChat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "public_chats" do
    field :name, :string
    field :description, :string
    field :uuid, :string
    field :created, :boolean

    belongs_to :image, Tcb.Image
    belongs_to :hashtag, Tcb.Hashtag

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :description, :uuid, :created, :image_id, :hashtag_id])
    |> validate_required([:name, :uuid, :created])
    |> validate_length(:name, max: 300)
    |> validate_length(:description, max: 300)
  end
end
