# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ApiApp.Repo.insert!(%ApiApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
IO.puts("Adding a couple of users...")

ApiApp.Account.create_user(%{username: "user1", password: "qwerty"})
ApiApp.Account.create_user(%{username: "user2", password: "asdfgh"})
