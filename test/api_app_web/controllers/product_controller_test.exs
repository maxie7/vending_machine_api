defmodule ApiAppWeb.ProductControllerTest do
  use ApiAppWeb.ConnCase

  alias ApiApp.Account
  alias ApiApp.Sales
  alias Plug.Test

  # alias ApiAppWeb.Router.Helpers, as: Routes

  @current_user_attrs %{
    id: "some_buyer_id",
    username: "some_current_user_username",
    password: "some_current_user_password",
    is_active: true,
    # role: "buyer",
    deposit: 250
  }

  @current_seller_user_attrs %{
    id: "some_seller_id",
    username: "some__user_username",
    password: "some__user_password",
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

  describe "buy/2" do
    test "allows buyer to purchase product if they have enough funds", %{conn: conn, current_user: current_user} do
      {:ok, seller} = Account.create_user(@current_seller_user_attrs)
      {:ok, product} = Sales.create_product(%{product_name: "some product", cost: 10, amount_available: 5, seller_id: seller.id})
      conn = post(conn, ~p"/api/buy", %{product_id: product.id, product_amount: "1"})

      assert json_response(conn, 200) =~ ~r/Order completed/

      updated_user = Account.get_user!(current_user.id)
      assert updated_user.deposit == 240
    end

    test "returns 403 if buyer has insufficient funds", %{conn: conn, current_user: _current_user} do
      {:ok, seller} = Account.create_user(@current_seller_user_attrs)
      {:ok, product} = Sales.create_product(%{product_name: "some product 2", cost: 500, amount_available: 5, seller_id: seller.id})

      conn = post(conn, ~p"/api/buy", %{product_id: product.id, product_amount: "5"})

      assert json_response(conn, 403) =~ "Insufficient funds"
    end

    # test "returns 403 if seller tries to buy product", %{conn: conn, current_user: current_user} do
    #   current_user = %{current_user | role: "seller"}
    #   {:ok, product} = Sales.create_product(%{product_name: "some product 3", cost: 1, amount_available: 15, seller_id: current_user.id})
    #   IO.inspect(product, label: "product")
    #   IO.inspect(current_user, label: "current_user")
    #   conn = post(conn, ~p"/api/buy", %{product_id: product.id, product_amount: "1"})
    #   IO.inspect(conn, label: "conn")

    #   assert json_response(conn, 403) =~ "Seller role cannot buy a product"
    # end
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
