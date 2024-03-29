defmodule ApiAppWeb.ProductController do
  use ApiAppWeb, :controller

  alias ApiApp.Account
  alias ApiApp.Helpers.ChangeCalculator
  alias ApiApp.Helpers.ListFormatter
  alias ApiApp.Sales
  alias ApiApp.Sales.Product

  action_fallback ApiAppWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    products = Sales.list_products()
    render(conn, :index, products: products)
  end

  @spec create(
          atom()
          | %{
              :private => atom() | %{:plug_session => map(), optional(any()) => any()},
              optional(any()) => any()
            },
          map()
        ) :: any()
  def create(conn, %{"product" => product_params}) do
    %{"current_user_id" => current_user_id} = conn.private.plug_session
    user = Account.get_user!(current_user_id)

    case user.role do
      "buyer" ->
        send_resp(conn, 403, "Buyer role can't create a product")

      "seller" ->
        if user.id == product_params["seller_id"] do
          with {:ok, %Product{} = product} <- Sales.create_product(product_params) do
            conn
            |> put_status(:created)
            |> put_resp_header("location", ~p"/api/products/#{product}")
            |> render(:show, product: product)
          end
        else
          send_resp(conn, 403, "You have only permission to create a product with your seller id")
        end
    end
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    product = Sales.get_product!(id)
    render(conn, :show, product: product)
  end

  @spec update(
          atom()
          | %{
              :private => atom() | %{:plug_session => map(), optional(any()) => any()},
              optional(any()) => any()
            },
          map()
        ) :: any()
  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Sales.get_product!(id)
    %{"current_user_id" => current_user_id} = conn.private.plug_session
    user = Account.get_user!(current_user_id)

    case user.role do
      "buyer" ->
        send_resp(conn, 403, "Buyer role can't update a product")

      "seller" ->
        if user.id == product_params["seller_id"] do
          with {:ok, %Product{} = product} <- Sales.update_product(product, product_params) do
            render(conn, :show, product: product)
          end
        else
          send_resp(conn, 403, "You have only permission to update a product with your seller id")
        end
    end
  end

  @spec delete(
          atom()
          | %{
              :private => atom() | %{:plug_session => map(), optional(any()) => any()},
              optional(any()) => any()
            },
          map()
        ) :: any()
  def delete(conn, %{"id" => id}) do
    product = Sales.get_product!(id)
    %{"current_user_id" => current_user_id} = conn.private.plug_session
    user = Account.get_user!(current_user_id)

    case user.role do
      "buyer" ->
        send_resp(conn, 403, "Buyer role can't delete a product")

      "seller" ->
        if user.id == product.seller_id do
          with {:ok, %Product{}} <- Sales.delete_product(product) do
            send_resp(conn, :no_content, "")
          end
        else
          send_resp(conn, 403, "You have only permission to delete a product with your seller id")
        end
    end
  end

  @spec buy(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def buy(conn, %{"product_id" => product_id, "product_amount" => product_amount}) do
    product_amount = String.to_integer(product_amount)
    %{"current_user_id" => current_user_id} = conn.private.plug_session

    user = Account.get_user!(current_user_id)
    product = Sales.get_product!(product_id)
    order_cost = product_amount * product.cost

    case user.role do
      "buyer" ->
        if user.deposit >= order_cost && product_amount <= product.amount_available do
          {:ok, user} = Account.deposit(user, %{deposit: -order_cost})
          {:ok, _product} = Sales.update_product(product, %{amount_available: product.amount_available - product_amount})

          resp_body = "Order completed!
            Total spent: #{order_cost};
            product #{product.product_name} purchased;
            Your change (#{user.deposit}) in coins: #{
              user.deposit
              |> ChangeCalculator.calculate_change()
              |> ListFormatter.format_list()
            }"

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Jason.encode!(resp_body))
        else
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(403, Jason.encode!("Insufficient funds"))
        end

      "seller" ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!("Seller role cannot buy a product"))
    end
  end
end
