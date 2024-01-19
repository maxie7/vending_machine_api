defmodule ApiAppWeb.UserController do
  use ApiAppWeb, :controller

  alias ApiApp.Account
  alias ApiApp.Account.User

  action_fallback ApiAppWeb.FallbackController

  def index(conn, _params) do
    users = Account.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Account.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Account.get_user!(id)

    with {:ok, %User{} = user} <- Account.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Account.get_user!(id)

    with {:ok, %User{}} <- Account.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"username" => username, "password" => password}) do
    case ApiApp.Account.authenticate_user(username, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> configure_session(renew: true)
        |> put_status(:ok)
        |> put_view(ApiAppWeb.UserView)
        |> render("sign_in.json", user: user)

      {:error, message} ->
        conn
        |> delete_session(:current_user_id)
        |> put_status(:unauthorized)
        |> put_view(ApiAppWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  def deposit(conn, %{"amount" => amount}) do
    amount = String.to_integer(amount)
    %{"current_user_id" => current_user_id} = conn.private.plug_session
    user = Account.get_user!(current_user_id)

    case user.role do
      "buyer" ->
        if amount in [5, 10, 20, 50, 100] do
          {:ok, user} = Account.deposit(user, %{deposit: amount})
          render(conn, :show, user: user)
        else
          send_resp(conn, 403, "Invalid amount")
        end

      "seller" ->
        send_resp(conn, 403, "Seller can't deposit")
    end
  end
end
