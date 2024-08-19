defmodule Tcb.ValidatePasswordTest do
  use TcbWeb.ConnCase
  alias Tcb.User

  test "validate password" do
    assert !User.valid_password("foo")
    assert !User.valid_password("foobar")
    assert User.valid_password("fooBar")
    assert !User.valid_password("foo Bar")
    assert User.valid_password("foo1Bar")
    assert User.valid_password("foo$Bar")
    assert !User.valid_password("foo$Barfoo$Barfoo$Barfoo$Barfoo$Barfoo$Barfoo$Barfoo$Barfoo$Barfoo$Barfoo")
  end
end
