defmodule Coolors.PageletsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Coolors.Pagelets` context.
  """

  @doc """
  Generate a operator.
  """
  def operator_fixture(attrs \\ %{}) do
    {:ok, operator} =
      attrs
      |> Enum.into(%{
        name: "some name",
        owner: "7488a646-e31f-11e4-aace-600308960662",
        secret: "some secret"
      })
      |> Coolors.Pagelets.create_operator()

    operator
  end
end
