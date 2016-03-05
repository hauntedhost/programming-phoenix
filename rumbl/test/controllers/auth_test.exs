defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth
  alias Rumbl.User

  setup(%{conn: conn}) do
    conn = conn
    |> bypass_through(Rumbl.Router, :browser)
    |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn = conn
    |> assign(:current_user, %User{id: 123})
    |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    user_id = Ecto.UUID.generate
    login_conn = conn
    |> Auth.login(%User{id: user_id})
    |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")

    assert get_session(next_conn, :user_id) == user_id
  end

  test "logout drops the session", %{conn: conn} do
    user_id = Ecto.UUID.generate
    logout_conn = conn
    |> put_session(:user_id, user_id)
    |> Auth.logout
    |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")

    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn = conn
    |> put_session(:user_id, user.id)
    |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)

    assert conn.assigns.current_user == nil
  end

  test "login with a valid email and pass", %{conn: conn} do
    user = insert_user(%{username: "batman", password: "supersecret"})
    {:ok, conn} = Auth.login_by_username_and_pass(conn, "batman", "supersecret", repo: Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} =
      Auth.login_by_username_and_pass(conn, "ghost", "secret", repo: Repo)
  end

  test "login with password mismatch", %{conn: conn} do
    user = insert_user(%{username: "batman", password: "supersecret"})
    assert {:error, :unauthorized, _conn} =
      Auth.login_by_username_and_pass(conn, "batman", "wrongpass", repo: Repo)
  end
end
