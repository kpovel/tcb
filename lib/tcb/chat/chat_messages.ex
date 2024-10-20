defmodule Tcb.Chat.ChatMessages do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :message, :string
    belongs_to :chat_member, Tcb.Chat.ChatMembers
    belongs_to :public_chat, Tcb.Chat.PublicChat

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:message, :chat_member_id, :public_chat_id])
    |> validate_required([:message, :chat_member_id, :public_chat_id])
  end
end
