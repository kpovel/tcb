defmodule Tcb.AccessToken do
  use Ecto.Schema
  alias Tcb.AccessToken
  alias Tcb.Token
  import Ecto.Query
  alias Tcb.Repo

  @token_validity_minutes 15

  schema "access_tokens" do
    belongs_to :refresh_token, Tcb.RefreshToken
    field :token, :binary
    field :expired_at, :utc_datetime
  end

  def issue_access_token(refresh_token_id) do
    token = Token.generate_token()
    Repo.query!("delete from access_tokens where refresh_token_id = $1;", [refresh_token_id])

    expired_at =
      DateTime.utc_now()
      |> DateTime.add(@token_validity_minutes, :minute)
      |> DateTime.truncate(:second)

    %AccessToken{refresh_token_id: refresh_token_id, token: token, expired_at: expired_at}
    |> Tcb.Repo.insert!()

    token |> Token.encode_token()
  end

  def validate_token(token) do
    token = token |> Token.decode_token()

    Tcb.AccessToken
    |> where([t], t.token == ^token)
    |> select([:id, :expired_at])
    |> Repo.one()
    |> case do
      nil ->
        false

      %Tcb.AccessToken{id: id, expired_at: expired_at} ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        case DateTime.compare(expired_at, now) do
          :gt ->
            {true, id}

          _ ->
            Repo.query!("delete from access_tokens where id = $1;", [id])
            false
        end
    end
  end
end
