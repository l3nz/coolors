defmodule Coolors.Pagelets.Operator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pagelets" do
    field :name, :string
    field :owner, Ecto.UUID
    field :secret, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(operator, attrs) do
    operator
    |> cast(attrs, [:name, :owner, :secret])
    |> validate_required([:name, :owner, :secret])
  end
end
