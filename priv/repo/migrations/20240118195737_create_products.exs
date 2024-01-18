defmodule ApiApp.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :product_name, :string, null: false
      add :cost, :integer
      add :seller_id, :string, null: false
      add :amount_available, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:products, [:product_name])
  end
end
