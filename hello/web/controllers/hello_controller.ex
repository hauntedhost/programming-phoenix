defmodule Hello.HelloController do
  use Hello.Web, :controller

  def world(conn, %{"name" => name}) do
    render(conn, "world.html", name: name)
  end

  def world(conn, _params) do
    render(conn, "world.html", name: "World!")
  end
end