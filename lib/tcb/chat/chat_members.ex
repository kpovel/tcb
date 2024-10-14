defmodule Tcb.Chat.ChatMembers do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_members" do
    belongs_to :chat, Tcb.Chat.PublicChat
    belongs_to :user, Tcb.User
    field :owner, :boolean

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:chat_id, :user_id, :owner])
    |> validate_required([:chat_id, :user_id, :owner])
  end
end
