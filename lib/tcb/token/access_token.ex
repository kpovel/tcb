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

  @spec user_by_access_token_id(integer()) :: %Tcb.User{} | nil
  def user_by_access_token_id(access_token_id) do
    %{rows: rows} =
      Repo.query!(
        "select u.id,
       u.login,
       u.nickname,
       u.email,
       u.validate_email_id,
       u.password,
       u.onboarded,
       u.avatar_id,
       u.about_me
from access_tokens ac
         inner join refresh_tokens rt on rt.id = ac.refresh_token_id
         inner join users u on rt.user_id = u.id
where ac.id = ?1",
        [access_token_id]
      )

    user = rows |> Enum.at(0)

    case user do
      nil ->
        nil

      [id, login, nickname, email, validate_email_id, password, onboarded, avatar_id, about_me] ->
        %Tcb.User{
          id: id,
          login: login,
          nickname: nickname,
          email: email,
          validate_email_id: validate_email_id,
          password: password,
          onboarded: onboarded,
          avatar_id: avatar_id,
          about_me: about_me
        }
    end
  end
end
