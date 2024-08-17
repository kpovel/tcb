defmodule Tcb.User.UserNotifier do
  import Swoosh.Email
  alias Tcb.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Tereveni", "chat.creators.01@gmail.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_confirmation_confirm_email(%Tcb.User{} = user) do
    link = "http://localhost:4000/en/validate-email/#{user.validate_email.code}"

    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.nickname},

    You can confirm your email account by visiting the URL below:

    <a href="#{link}">
      #{link}
    </a>

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end
end
