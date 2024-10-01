defmodule Tcb.UserHashtag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_hashtags" do
    belongs_to :user, Tcb.User
    belongs_to :hashtag, Tcb.Hashtag
  end

  @doc false
  def changeset(user_hashtags, attrs) do
    user_hashtags
    |> cast(attrs, [:user_id, :hashtag_id])
    |> validate_required([:user_id, :hashtag_id])
  end
end
