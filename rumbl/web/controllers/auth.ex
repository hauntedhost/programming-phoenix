defmodule Rumbl.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller
  alias Rumbl.Router.Helpers
  alias Rumbl.User

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    cond do
      user = current_user(conn) ->
        conn
      user = user_id && repo.get(User, user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def current_user(conn) do
    conn.assigns[:current_user]
  end

  def authenticate_user(conn, _opts) do
    if current_user(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(User, username: username)
    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def login(conn, user = %User{id: user_id}) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user_id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> delete_assign(:current_user)
    |> delete_session(:user_id)
  end

  defp delete_assign(conn, key) do
    Map.update!(conn, :assigns, &Map.delete(&1, key))
  end
end
