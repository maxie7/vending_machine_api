defmodule ApiApp.Repo.Migrations.AddDepositAndRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :deposit, :integer, default: 0
      add :role, :string, default: "buyer"
    end
  end
end
