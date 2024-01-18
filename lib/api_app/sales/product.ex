defmodule ApiApp.Sales.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field :product_name, :string
    field :cost, :integer
    field :seller_id, :string
    field :amount_available, :integer

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:product_name, :cost, :seller_id, :amount_available])
    |> validate_required([:product_name, :cost, :seller_id, :amount_available])
    |> unique_constraint(:product_name)
  end
end
