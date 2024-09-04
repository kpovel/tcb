defmodule Tcb.RefreshToken do
  alias Tcb.Repo
  alias Tcb.RefreshToken
  alias Tcb.Token
  use Ecto.Schema
  import Ecto.Query

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

  def validate_token(token) do
    token = token |> Token.decode_token()

    Tcb.RefreshToken
    |> where([t], t.token == ^token)
    |> select([:id, :expired_at])
    |> Repo.one()
    |> case do
      nil ->
        false

      %Tcb.RefreshToken{id: id, expired_at: expired_at} ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        case DateTime.compare(expired_at, now) do
          :gt ->
            {true, id}

          _ ->
            Repo.query!("delete from access_tokens where refresh_token_id = $1;", [id])
            Repo.query!("delete from refresh_tokens where id = $1;", [id])
            false
        end
    end
  end
end
