defmodule Tcb.Chat.PublicChat do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Tcb.Repo

  schema "public_chats" do
    field :name, :string
    field :description, :string
    field :uuid, :string
    field :created, :boolean

    belongs_to :image, Tcb.Image
    # It is actually a reference to hashtag_id in the hashtags table
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

  def chat_owner(chat_uuid, user_id) do
    from(pc in __MODULE__,
      join: cm in Tcb.Chat.ChatMembers,
      on: pc.id == cm.chat_id,
      where: pc.uuid == ^chat_uuid and cm.user_id == ^user_id and cm.owner,
      select: [pc.id]
    )
    |> Repo.one()
    |> case do
      nil -> false
      _ -> true
    end
  end
end
