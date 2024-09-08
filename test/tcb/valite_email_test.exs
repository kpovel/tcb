defmodule Tcb.ValidateEmailTest do
  use TcbWeb.ConnCase
  alias Tcb.User

  test "validate email addresses" do
    assert User.validate_email("foo@foo.com")
    assert User.validate_email("a@b.co")
    assert User.validate_email("a+420@b.co")
    assert User.validate_email("a.c.b@b.co")
    refute User.validate_email("a..b@b.co")
    refute User.validate_email("@b.co")
    refute User.validate_email("")
    refute User.validate_email(nil)
  end
end
