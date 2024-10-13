defmodule Tcb.Chat.ChatMessages do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :message, :string
    belongs_to :chat_member, Tcb.Chat.ChatMembers

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:message, :chat_member_id])
    |> validate_required([:message, :chat_member_id])
  end
end
