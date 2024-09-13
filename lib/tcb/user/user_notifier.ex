defmodule Tcb.User.UserNotifier do
  alias Tcb.Mailer
  import Swoosh.Email

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Tereveni", "no_replay@tereveni.software"})
      |> subject(subject)
      |> html_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_confirmation_confirm_email(%Tcb.User{} = user, lang, host) do
    link = "#{host}/#{lang}/validate-email/#{user.validate_email.code}"

    deliver(user.email, "Confirmation instructions", """
    <p>==============================</p>
    <h1>Hi #{user.nickname},</h1>
    <p>
      You can confirm your email account by visiting the URL below:
    </p>
    <p><a href="#{link}">#{link}</a></p>
    <p>
      If you didn't create an account with us, please ignore this.
    </p>
    <p>==============================</p>
    """)
  end
end
