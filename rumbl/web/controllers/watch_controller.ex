defmodule Rumbl.WatchController do
  use Rumbl.Web, :controller
  alias Rumbl.Video

  def show(conn, %{"id" => id}) do
    video = Repo.get_by_uuid!(Video, id)
    render(conn, "show.html", video: video)
  end
end
