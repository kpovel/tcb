defmodule TcbWeb.AuthController do
  alias Tcb.Repo
  alias Tcb.ValidateEmailCodes
  alias Tcb.User
  use TcbWeb, :controller

  def signup(conn, %{"login" => login, "email" => email, "password" => password}) do
    errors = %{login: "", password: "", email: ""}
    emailInUse = email |> User.exists_user_with_email()
    loginInUse = login |> User.exists_user_with_login()
    strongPassword = String.length(password) > 5

    errors =
      case emailInUse do
        true -> Map.put(errors, :email, "Try to use another email")
        false -> errors
      end

    errors =
      case loginInUse do
        true -> Map.put(errors, :login, "Login already in use")
        false -> errors
      end

    errors =
      case !strongPassword do
        true -> Map.put(errors, :password, "Create a strong password")
        false -> errors
      end

    case [emailInUse, loginInUse, strongPassword] do
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
