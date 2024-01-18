defmodule ApiAppWeb.ProductJSON do
  alias ApiApp.Sales.Product

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      product_name: product.product_name,
      cost: product.cost,
      seller_id: product.seller_id,
      amount_available: product.amount_available
    }
  end
end
