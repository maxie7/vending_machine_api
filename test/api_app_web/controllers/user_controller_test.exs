defmodule ApiAppWeb.UserControllerTest do
  use ApiAppWeb.ConnCase

  import ApiApp.AccountFixtures

  alias ApiApp.Account
  alias ApiApp.Account.User
  alias Plug.Test
  alias ApiAppWeb.Router.Helpers, as: Routes

  @create_attrs %{
    username: "some_username",
    password: "some_password",
    is_active: true
  }
  @update_attrs %{
    username: "some_updated_username",
    password: "some_updated_password",
    is_active: false
  }
  @invalid_attrs %{username: nil, password: nil, is_active: nil}
  @current_user_attrs %{
    username: "some_current_user_username",
    is_active: true,
    password: "some_current_user_password"
  }

  def fixture(:user) do
    {:ok, user} = Account.create_user(@create_attrs)
    user
  end

  def fixture(:current_user) do
    {:ok, current_user} = Account.create_user(@current_user_attrs)
    current_user
  end

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user(conn)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: current_user}
  end

  describe "index" do
    test "lists all users", %{conn: conn, current_user: current_user} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 200)["data"] == [
        %{
          "id" => current_user.id,
          "username" => current_user.username,
          "is_active" => current_user.is_active,
          "password" => nil
        }
      ]
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "is_active" => true,
               "username" => "some_username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "is_active" => false,
               "username" => "some_updated_username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/users/#{user}")
      end
    end
  end

  describe "sign in user" do
    test "renders user when user credentials are good", %{
      conn: conn,
      current_user: current_user
    } do
      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            username: current_user.username,
            password: @current_user_attrs.password
          })
        )

      assert json_response(conn, 200)["data"] == %{
               "user" => %{
                 "id" => current_user.id,
                 "username" => current_user.username
               }
             }
    end

    test "renders error when user credentials are bad", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            username: "non-existent username",
            password: ""
          })
        )

      assert json_response(conn, 401)["errors"] == %{
               "detail" => "Wrong username or password"
             }
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
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
