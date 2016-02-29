defmodule Rumbl.UserController do
  use Rumbl.Web, :controller

  def index(conn, _params) do
    users = Repo.all(Rumbl.User)
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"username" => username}) do
    user = Repo.get_by(Rumbl.User, %{username: username})
    render(conn, "show.html", user: user)
  end
end
