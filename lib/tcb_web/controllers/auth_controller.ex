defmodule TcbWeb.AuthController do
  alias Tcb.Repo
  alias Tcb.ValidateEmailCodes
  alias Tcb.User
  use TcbWeb, :controller

  def signup(conn, %{"login" => login, "email" => email, "password" => password}) do
    # X-Originating-Host

    errors = %{login: "", password: "", email: ""}
    emailInUse = email |> User.exists_user_with_email()
    loginInUse = login |> User.exists_user_with_login()
    valid_password = password |> User.valid_password()
    valid_email = User.validate_email(email)

    errors =
      case valid_email do
        false -> Map.put(errors, :email, TcbWeb.Gettext.dgettext("signup", "Enter a valid email"))
        true -> errors
      end

    errors =
      case valid_email && emailInUse do
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
            password: password,
            onboarded: false,
            validate_email: validate_email_schema
          }
          |> Repo.insert!()

        Tcb.User.UserNotifier.deliver_confirmation_confirm_email(user)

        conn |> send_resp(201, "")

      _ ->
        conn |> render(:signup, errors)
    end
  end

  def signup(conn, _params) do
    conn |> send_resp(400, "")
  end
end
