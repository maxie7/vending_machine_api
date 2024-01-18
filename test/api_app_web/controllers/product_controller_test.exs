defmodule ApiAppWeb.ProductControllerTest do
  use ApiAppWeb.ConnCase

  import ApiApp.SalesFixtures

  alias ApiApp.Account
  alias ApiApp.Sales.Product
  alias Plug.Test

  @create_attrs %{
    product_name: "some product_name",
    cost: 42,
    seller_id: "some seller_id",
    amount_available: 42
  }
  @update_attrs %{
    product_name: "some updated product_name",
    cost: 43,
    seller_id: "some updated seller_id",
    amount_available: 43
  }
  @invalid_attrs %{product_name: nil, cost: nil, seller_id: nil, amount_available: nil}
  @current_user_attrs %{
    username: "some_current_user_username",
    is_active: true,
    password: "some_current_user_password"
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

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "amount_available" => 42,
               "cost" => 42,
               "product_name" => "some product_name",
               "seller_id" => "some seller_id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "amount_available" => 43,
               "cost" => 43,
               "product_name" => "some updated product_name",
               "seller_id" => "some updated seller_id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/products/#{product}")
      end
    end
  end

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
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
