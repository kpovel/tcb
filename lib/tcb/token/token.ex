defmodule Tcb.Token do
  @rand_size 32

  def generate_token() do
    :crypto.strong_rand_bytes(@rand_size)
  end

  def encode_token(token) when is_binary(token) do
    Base.encode64(token, padding: false)
  end

  def decode_token(token) when is_binary(token) do
    {:ok, decoded} = Base.decode64(token, padding: false)
    decoded
  end
end
