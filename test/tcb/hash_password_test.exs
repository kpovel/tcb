defmodule Tcb.HashPasswordTest do
  use TcbWeb.ConnCase

  @password "foo"
  test "hash password" do
    hashed = Bcrypt.hash_pwd_salt(@password)

    true = Bcrypt.verify_pass(@password, hashed)
    false = Bcrypt.verify_pass("bar", hashed)
  end
end
