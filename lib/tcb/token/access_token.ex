defmodule Tcb.AccessToken do
  use Ecto.Schema
  alias Tcb.AccessToken
  alias Tcb.Token

  @token_validity_minutes 15

  schema "access_tokens" do
    belongs_to :refresh_token, Tcb.RefreshToken
    field :token, :binary
    field :expired_at, :utc_datetime
  end

  def issue_access_token(refresh_token_id) do
    token = Token.generate_token()

    expired_at =
      DateTime.utc_now()
      |> DateTime.add(@token_validity_minutes, :minute)
      |> DateTime.truncate(:second)

    %AccessToken{refresh_token_id: refresh_token_id, token: token, expired_at: expired_at}
    |> Tcb.Repo.insert!()

    token |> Token.encode_token()
  end
end
