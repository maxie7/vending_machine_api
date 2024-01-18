defmodule ApiApp.SalesTest do
  use ApiApp.DataCase

  alias ApiApp.Sales

  describe "products" do
    alias ApiApp.Sales.Product

    import ApiApp.SalesFixtures

    @invalid_attrs %{product_name: nil, cost: nil, seller_id: nil, amount_available: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Sales.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Sales.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{product_name: "some product_name", cost: 42, seller_id: "some seller_id", amount_available: 42}

      assert {:ok, %Product{} = product} = Sales.create_product(valid_attrs)
      assert product.product_name == "some product_name"
      assert product.cost == 42
      assert product.seller_id == "some seller_id"
      assert product.amount_available == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{product_name: "some updated product_name", cost: 43, seller_id: "some updated seller_id", amount_available: 43}

      assert {:ok, %Product{} = product} = Sales.update_product(product, update_attrs)
      assert product.product_name == "some updated product_name"
      assert product.cost == 43
      assert product.seller_id == "some updated seller_id"
      assert product.amount_available == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_product(product, @invalid_attrs)
      assert product == Sales.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Sales.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Sales.change_product(product)
    end
  end
end
