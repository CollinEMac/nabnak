defmodule NabnakWeb.ErrorJSONTest do
  use NabnakWeb.ConnCase, async: true

  test "renders 404" do
    assert NabnakWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert NabnakWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
