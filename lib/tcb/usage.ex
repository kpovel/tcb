defmodule Tcb.Usage do
  use Ecto.Schema

  schema "usage" do
    field :count, :integer, default: 0
  end
end
