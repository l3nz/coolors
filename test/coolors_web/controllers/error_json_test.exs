defmodule CoolorsWeb.ErrorJSONTest do
  use CoolorsWeb.ConnCase, async: true

  test "renders 404" do
    assert CoolorsWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert CoolorsWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
