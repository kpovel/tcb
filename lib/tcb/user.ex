defmodule Tcb.User do
  use Ecto.Schema
  alias Ecto.Changeset
  import Ecto.Query

  schema "users" do
    field :login, :string
    field :nickname, :string
    field :email, :string
    field :password, :string
    field :onboarded, :boolean
    field :about_me, :string
    belongs_to :validate_email, Tcb.ValidateEmailCodes
    belongs_to :avatar, Tcb.Image
  end

  def changeset(user, params \\ %{}) do
    user
    |> Changeset.cast(params, [
      :login,
      :nickname,
      :email,
      :password,
      :onboarded,
      :about_me
    ])
    |> Changeset.validate_required([
      :login,
      :nickname,
      :email,
      :password,
      :onboarded
    ])
    |> Changeset.unique_constraint(:login)
    |> changeset_validate_email()
  end

  defp changeset_validate_email(changeset) do
    changeset
    |> Changeset.validate_required([:email])
    |> Changeset.unique_constraint(:email)
    |> Changeset.validate_change(:email, fn :email, email ->
      if email |> validate_email() do
        [email: "Invalid email"]
      else
        []
      end
    end)
  end

  @doc """
    Validate login and nicknames
  """
  def valid_login(password) when not is_binary(password), do: false
  def valid_login(password) when byte_size(password) < 3, do: false
  def valid_login(password) when byte_size(password) > 50, do: false

  def valid_login(password) do
    String.to_charlist(password)
    |> Enum.all?(&((&1 >= 65 && &1 <= 90) || (&1 >= 97 && &1 <= 122)))
  end

  def valid_password(password) when not is_binary(password), do: false
  def valid_password(password) when byte_size(password) < 6, do: false
  def valid_password(password) when byte_size(password) > 72, do: false

  def valid_password(password) do
    cond do
      String.contains?(password, " ") ->
        false

      !(String.to_charlist(password) |> Enum.any?(&(&1 >= 65 && &1 <= 90))) ->
        false

      !(String.to_charlist(password) |> Enum.any?(&(&1 >= 97 && &1 <= 122))) ->
        false

      true ->
        true
    end
  end

  def validate_email(email) when not is_binary(email), do: false

  def validate_email(email) do
    email
    |> String.match?(
      ~r/^(?!\.)(?!.*\.\.)([A-Z0-9_'+\-\.]*)[A-Z0-9_+-]@([A-Z0-9][A-Z0-9\-]*\.)+[A-Z]{2,}$/i
    )
  end

  @spec exists_user_with_email(String.t()) :: boolean()
  def exists_user_with_email(email) do
    Tcb.User
    |> where([u], u.email == ^email)
    |> select([u], {u.id})
    |> Tcb.Repo.one()
    |> case do
      {_id} -> true
      nil -> false
    end
  end

  @spec exists_user_with_login(String.t()) :: boolean()
  def exists_user_with_login(login) do
    Tcb.User
    |> where([u], u.login == ^login)
    |> select([u], {u.id})
    |> Tcb.Repo.one()
    |> case do
      {_id} -> true
      nil -> false
    end
  end
end
