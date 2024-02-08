defmodule ApiAppWeb.UserController do
  use ApiAppWeb, :controller

  alias ApiApp.Account
  alias ApiApp.Account.User

  action_fallback ApiAppWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    users = Account.list_users()
    render(conn, :index, users: users)
  end

  @spec create(any(), map()) :: any()
  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Account.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    render(conn, :show, user: user)
  end

  @spec logout_all(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def logout_all(conn, %{"username" => username, "password" => password}) do
    case Account.authenticate_user(username, password) do
      {:ok, user} ->
        {:ok, _user} = Account.change_active_field(user, %{is_active: false})
        conn
        |> delete_session(:current_user_id)
        |> put_status(:ok)
        |> put_view(ApiAppWeb.UserView)
        |> render("sign_in.json", user: user)

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(ApiAppWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  @spec update(
          atom()
          | %{
              :private => atom() | %{:plug_session => map(), optional(any()) => any()},
              optional(any()) => any()
            },
          map()
        ) :: any()
  def update(conn, %{"id" => _id, "user" => user_params}) do
    %{"current_user_id" => current_user_id} = conn.private.plug_session
    user = Account.get_user!(current_user_id)

    with {:ok, %User{} = user} <- Account.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  @spec delete(any(), map()) :: any()
  def delete(conn, %{"id" => id}) do
    user = Account.get_user!(id)

    with {:ok, %User{}} <- Account.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  @spec sign_in(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def sign_in(conn, %{"username" => username, "password" => password}) do
    case Account.authenticate_user(username, password) do
      {:ok, user} ->
        if user.is_active do
          conn
          |> delete_session(:current_user_id)
          |> put_status(:unauthorized)
          |> put_view(ApiAppWeb.ErrorView)
          |> render("401.json", message: "There is already an active session using your account")
        else
          {:ok, _user} = Account.change_active_field(user, %{is_active: true})
          conn
          |> put_session(:current_user_id, user.id)
          |> configure_session(renew: true)
          |> put_status(:ok)
          |> put_view(ApiAppWeb.UserView)
          |> render("sign_in.json", user: user)
        end

      {:error, message} ->
        conn
        |> delete_session(:current_user_id)
        |> put_status(:unauthorized)
        |> put_view(ApiAppWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  @spec deposit(Plug.Conn.t(), map()) :: Plug.Conn.t()
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

  @spec reset(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def reset(conn, _params) do
    %{"current_user_id" => current_user_id} = conn.private.plug_session
    user = Account.get_user!(current_user_id)

    case user.role do
      "buyer" ->
        if user.deposit > 0 do
          {:ok, user} = Account.deposit(user, %{deposit: 0})
          render(conn, :show, user: user)
        else
          send_resp(conn, 406, "Nothing to reset")
        end

      "seller" ->
        send_resp(conn, 403, "Seller has no deposit")
    end
  end
end
