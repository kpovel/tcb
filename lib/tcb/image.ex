defmodule Tcb.Image do
  use Ecto.Schema

  schema "image" do
    field :name, :string
    field :value, :binary
  end
end
