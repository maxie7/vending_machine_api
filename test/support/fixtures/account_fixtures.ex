defmodule ApiApp.AccountFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ApiApp.Account` context.
  """

  @doc """
  Generate a unique user username.
  """
  def unique_user_username, do: "some username#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: unique_user_username(),
        is_active: true,
        password: "some_password"
      })
      |> ApiApp.Account.create_user()

    user
  end
end
