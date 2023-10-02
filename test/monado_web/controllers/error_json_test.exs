defmodule MonadoWeb.ErrorJSONTest do
  use MonadoWeb.ConnCase, async: true

  test "renders 404" do
    assert MonadoWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert MonadoWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
