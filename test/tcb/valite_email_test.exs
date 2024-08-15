defmodule Tcb.ValidateEmailTest do
  use TcbWeb.ConnCase
  alias Tcb.User

  test "validate email addresses" do
    assert User.valitate_email("foo@foo.com")
    assert User.valitate_email("a@b.co")
    assert User.valitate_email("a+420@b.co")
    assert User.valitate_email("a.c.b@b.co")
    refute User.valitate_email("a..b@b.co")
    refute User.valitate_email("@b.co")
    refute User.valitate_email("")
    refute User.valitate_email(nil)
  end
end
