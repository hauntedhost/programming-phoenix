defmodule Hello.HelloController do
  use Hello.Web, :controller

  def world(conn, params) do
    render(conn, "world.html", name: params["name"] || "World")
  end
end
