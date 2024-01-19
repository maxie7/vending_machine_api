defmodule ApiAppWeb.ProductControllerTest do
  use ApiAppWeb.ConnCase

  alias ApiApp.Account
  alias Plug.Test

  @current_user_attrs %{
    id: "some_seller_id",
    username: "some_current_user_username",
    password: "some_current_user_password",
    is_active: true,
    role: "seller"
  }

  def fixture(:current_user) do
    {:ok, current_user} = Account.create_user(@current_user_attrs)
    current_user
  end

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user(conn)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: current_user}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  defp setup_current_user(conn) do
    current_user = fixture(:current_user)

    {
      :ok,
      conn: Test.init_test_session(conn, current_user_id: current_user.id),
      current_user: current_user
    }
  end
end
