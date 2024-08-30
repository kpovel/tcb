defmodule Tcb.RefreshToken do
  alias Tcb.RefreshToken
  alias Tcb.Token
  use Ecto.Schema

  @token_validity_days 150

  schema "refresh_tokens" do
    belongs_to :user, Tcb.User
    field :token, :binary
    field :expired_at, :utc_datetime
  end

  def issue_refresh_token(user_id) do
    token = Token.generate_token()

    expired_at =
      DateTime.utc_now()
      |> DateTime.add(@token_validity_days, :day)
      |> DateTime.truncate(:second)

    %RefreshToken{id: id} =
      %RefreshToken{user_id: user_id, token: token, expired_at: expired_at}
      |> Tcb.Repo.insert!()

    {token |> Token.encode_token(), id}
  end
end
