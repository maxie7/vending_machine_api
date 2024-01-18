defmodule ApiApp.SalesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ApiApp.Sales` context.
  """

  @doc """
  Generate a unique product product_name.
  """
  def unique_product_product_name, do: "some product_name#{System.unique_integer([:positive])}"

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        amount_available: 42,
        cost: 42,
        product_name: unique_product_product_name(),
        seller_id: "some seller_id"
      })
      |> ApiApp.Sales.create_product()

    product
  end
end
