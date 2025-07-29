defmodule CoolorsWeb.OperatorLiveTest do
  use CoolorsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Coolors.PageletsFixtures

  @create_attrs %{
    name: "some name",
    owner: "7488a646-e31f-11e4-aace-600308960662",
    secret: "some secret"
  }
  @update_attrs %{
    name: "some updated name",
    owner: "7488a646-e31f-11e4-aace-600308960668",
    secret: "some updated secret"
  }
  @invalid_attrs %{name: nil, owner: nil, secret: nil}

  defp create_operator(_) do
    operator = operator_fixture()
    %{operator: operator}
  end

  describe "Index" do
    setup [:create_operator]

    test "lists all pagelets", %{conn: conn, operator: operator} do
      {:ok, _index_live, html} = live(conn, ~p"/operator/pagelets")

      assert html =~ "Listing Pagelets"
      assert html =~ operator.name
    end

    test "saves new operator", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/operator/pagelets")

      assert index_live |> element("a", "New Operator") |> render_click() =~
               "New Operator"

      assert_patch(index_live, ~p"/operator/pagelets/new")

      assert index_live
             |> form("#operator-form", operator: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#operator-form", operator: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/operator/pagelets")

      html = render(index_live)
      assert html =~ "Operator created successfully"
      assert html =~ "some name"
    end

    test "updates operator in listing", %{conn: conn, operator: operator} do
      {:ok, index_live, _html} = live(conn, ~p"/operator/pagelets")

      assert index_live |> element("#pagelets-#{operator.id} a", "Edit") |> render_click() =~
               "Edit Operator"

      assert_patch(index_live, ~p"/operator/pagelets/#{operator}/edit")

      assert index_live
             |> form("#operator-form", operator: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#operator-form", operator: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/operator/pagelets")

      html = render(index_live)
      assert html =~ "Operator updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes operator in listing", %{conn: conn, operator: operator} do
      {:ok, index_live, _html} = live(conn, ~p"/operator/pagelets")

      assert index_live |> element("#pagelets-#{operator.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#pagelets-#{operator.id}")
    end
  end

  describe "Show" do
    setup [:create_operator]

    test "displays operator", %{conn: conn, operator: operator} do
      {:ok, _show_live, html} = live(conn, ~p"/operator/pagelets/#{operator}")

      assert html =~ "Show Operator"
      assert html =~ operator.name
    end

    test "updates operator within modal", %{conn: conn, operator: operator} do
      {:ok, show_live, _html} = live(conn, ~p"/operator/pagelets/#{operator}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Operator"

      assert_patch(show_live, ~p"/operator/pagelets/#{operator}/show/edit")

      assert show_live
             |> form("#operator-form", operator: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#operator-form", operator: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/operator/pagelets/#{operator}")

      html = render(show_live)
      assert html =~ "Operator updated successfully"
      assert html =~ "some updated name"
    end
  end
end
