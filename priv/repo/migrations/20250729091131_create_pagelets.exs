defmodule Coolors.Repo.Migrations.CreatePagelets do
  use Ecto.Migration

  def change do
    create table(:pagelets) do
      add :name, :string
      add :owner, :uuid
      add :secret, :string

      timestamps(type: :utc_datetime)
    end
  end
end
