defmodule Coolors.PageletsTest do
  use Coolors.DataCase

  alias Coolors.Pagelets

  describe "pagelets" do
    alias Coolors.Pagelets.Operator

    import Coolors.PageletsFixtures

    @invalid_attrs %{name: nil, owner: nil, secret: nil}

    test "list_pagelets/0 returns all pagelets" do
      operator = operator_fixture()
      assert Pagelets.list_pagelets() == [operator]
    end

    test "get_operator!/1 returns the operator with given id" do
      operator = operator_fixture()
      assert Pagelets.get_operator!(operator.id) == operator
    end

    test "create_operator/1 with valid data creates a operator" do
      valid_attrs = %{
        name: "some name",
        owner: "7488a646-e31f-11e4-aace-600308960662",
        secret: "some secret"
      }

      assert {:ok, %Operator{} = operator} = Pagelets.create_operator(valid_attrs)
      assert operator.name == "some name"
      assert operator.owner == "7488a646-e31f-11e4-aace-600308960662"
      assert operator.secret == "some secret"
    end

    test "create_operator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pagelets.create_operator(@invalid_attrs)
    end

    test "update_operator/2 with valid data updates the operator" do
      operator = operator_fixture()

      update_attrs = %{
        name: "some updated name",
        owner: "7488a646-e31f-11e4-aace-600308960668",
        secret: "some updated secret"
      }

      assert {:ok, %Operator{} = operator} = Pagelets.update_operator(operator, update_attrs)
      assert operator.name == "some updated name"
      assert operator.owner == "7488a646-e31f-11e4-aace-600308960668"
      assert operator.secret == "some updated secret"
    end

    test "update_operator/2 with invalid data returns error changeset" do
      operator = operator_fixture()
      assert {:error, %Ecto.Changeset{}} = Pagelets.update_operator(operator, @invalid_attrs)
      assert operator == Pagelets.get_operator!(operator.id)
    end

    test "delete_operator/1 deletes the operator" do
      operator = operator_fixture()
      assert {:ok, %Operator{}} = Pagelets.delete_operator(operator)
      assert_raise Ecto.NoResultsError, fn -> Pagelets.get_operator!(operator.id) end
    end

    test "change_operator/1 returns a operator changeset" do
      operator = operator_fixture()
      assert %Ecto.Changeset{} = Pagelets.change_operator(operator)
    end
  end
end
