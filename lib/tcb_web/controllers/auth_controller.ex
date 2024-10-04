defmodule TcbWeb.AuthController do
  alias Tcb.AccessToken
  alias Tcb.RefreshToken
  alias Tcb.Repo
  alias Tcb.ValidateEmailCodes
  alias Tcb.User
  import Ecto.Query
  use TcbWeb, :controller

  @originating_host "x-originating-host"
  @default_host "http://localhost:4000"

  def signup(%Plug.Conn{assigns: %{lang: lang}, req_headers: headers} = conn, %{
        "login" => login,
        "email" => email,
        "password" => password
      }) do
    host =
      Enum.find(headers, {@originating_host, @default_host}, fn {name, _} ->
        name == @originating_host
      end)
      |> elem(1)

    errors = %{login: "", password: "", email: ""}
    emailInUse = email |> User.exists_user_with_email()
    loginInUse = login |> User.exists_user_with_login()
    valid_login = login |> User.valid_login()
    valid_password = password |> User.valid_password()
    valid_email = User.validate_email(email)

    errors =
      case valid_email do
        false -> Map.put(errors, :email, TcbWeb.Gettext.dgettext("signup", "Enter a valid email"))
        true -> errors
      end

    errors =
      case emailInUse do
        true ->
          Map.put(errors, :email, TcbWeb.Gettext.dgettext("signup", "Email is already in use"))

        false ->
          errors
      end

    errors =
      case loginInUse do
        true ->
          Map.put(
            errors,
            :login,
            TcbWeb.Gettext.dgettext("signup", "Login is already in use")
          )

        false ->
          errors
      end

    errors =
      case valid_login do
        false ->
          Map.put(
            errors,
            :login,
            TcbWeb.Gettext.dgettext("signup", "Enter a valid login")
          )

        true ->
          errors
      end

    errors =
      case !valid_password do
        true ->
          Map.put(
            errors,
            :password,
            TcbWeb.Gettext.dgettext(
              "signup",
              "Create a strong password"
            )
          )

        false ->
          errors
      end

    case [emailInUse, loginInUse, valid_password] do
      [false, false, true] ->
        validate_email_schema =
          %ValidateEmailCodes{code: Ecto.UUID.generate(), validated_email: false}
          |> Tcb.Repo.insert!()

        user =
          %User{
            login: login,
            nickname: login,
            email: email,
            password: Bcrypt.hash_pwd_salt(password),
            onboarded: false,
            validate_email: validate_email_schema
          }
          |> Repo.insert!()

        Tcb.User.UserNotifier.deliver_confirmation_confirm_email(user, lang, host)

        conn |> send_resp(201, "")

      _ ->
        conn
        |> put_status(400)
        |> render(:signup, errors)
    end
  end

  def signup(conn, _params) do
    conn |> send_resp(400, "")
  end

  def login(%Plug.Conn{} = conn, %{"email" => email, "password" => password}) do
    from(Tcb.User,
      where: [email: ^email],
      select: [:id, :password]
    )
    |> Repo.one()
    |> case do
      nil ->
        conn
        |> put_status(400)
        |> render(:login_error, %{
          general:
            TcbWeb.Gettext.dgettext("login", "You have entered an incorrect email or password")
        })

      %Tcb.User{id: user_id, password: hashed_password} ->
        case Bcrypt.verify_pass(password, hashed_password) do
          false ->
            conn
            |> put_status(400)
            |> render(:login_error, %{
              general:
                TcbWeb.Gettext.dgettext(
                  "login",
                  "You have entered an incorrect email or password"
                )
            })

          true ->
            {refresh_token, token_id} = RefreshToken.issue_refresh_token(user_id)
            access_token = AccessToken.issue_access_token(token_id)

            conn
            |> render(
              :validate_email,
              %{refresh_token: refresh_token, access_token: access_token}
            )
        end
    end
  end

  def forgot_password(%Plug.Conn{assigns: %{lang: lang}, req_headers: headers} = conn, %{
        "userEmail" => email
      }) do
    host =
      Enum.find(headers, {@originating_host, @default_host}, fn {name, _} ->
        name == @originating_host
      end)
      |> elem(1)

    from(Tcb.User,
      where: [email: ^email],
      select: [:id, :email, :nickname]
    )
    |> Repo.one()
    |> case do
      nil ->
        conn
        |> send_resp(
          401,
          TcbWeb.Gettext.dgettext("reset_password", "You have entered an incorrect email")
        )

      %Tcb.User{id: user_id} = user ->
        from(r in Tcb.ResetPasswordCodes,
          where: r.user_id == ^user_id
        )
        |> Repo.delete_all()

        %Tcb.ResetPasswordCodes{code: code} =
          %Tcb.ResetPasswordCodes{user_id: user_id, code: Ecto.UUID.generate()}
          |> Repo.insert!()

        Tcb.User.UserNotifier.deliver_reset_password_email(user, code, lang, host)

        conn |> send_resp(201, "")
    end
  end

  def forgot_password_code(%Plug.Conn{} = conn, %{"code" => code}) do
    from(Tcb.ResetPasswordCodes,
      where: [code: ^code]
    )
    |> Repo.one()
    |> case do
      nil ->
        conn
        |> send_resp(401, "You did not initiate this password reset")

      %Tcb.ResetPasswordCodes{user_id: user_id} ->
        from(r in Tcb.ResetPasswordCodes,
          where: r.user_id == ^user_id
        )
        |> Repo.delete_all()

        {refresh_token, token_id} = RefreshToken.issue_refresh_token(user_id)
        access_token = AccessToken.issue_access_token(token_id)

        conn
        |> render(:validate_email, %{refresh_token: refresh_token, access_token: access_token})
    end
  end

  def validate_email(conn, %{"code" => code}) do
    Tcb.ValidateEmailCodes
    |> where([e], e.code == ^code)
    |> select([:code, :id, :validated_email])
    |> Repo.one()
    |> case do
      nil ->
        conn |> send_resp(400, "Something went wrong")

      %Tcb.ValidateEmailCodes{validated_email: true} ->
        conn |> send_resp(400, "Email was already validated")

      %Tcb.ValidateEmailCodes{id: validate_email_id} ->
        Repo.query!(
          "update validate_email_codes set validated_email = true where id = $1",
          [validate_email_id]
        )

        %Tcb.User{id: user_id} =
          from(Tcb.User,
            where: [validate_email_id: ^validate_email_id],
            select: [:id]
          )
          |> Repo.one()

        {refresh_token, token_id} = RefreshToken.issue_refresh_token(user_id)
        access_token = AccessToken.issue_access_token(token_id)

        conn
        |> render(:validate_email, %{refresh_token: refresh_token, access_token: access_token})
    end
  end
end
