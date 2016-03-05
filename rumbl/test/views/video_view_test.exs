defmodule Rumbl.VideoViewTest do
  use Rumbl.ConnCase, async: true
  import Phoenix.View
  alias Rumbl.Video
  alias Rumbl.VideoView

  test "renders index.html", %{conn: conn} do
    videos = [
      %Video{id: "1", title: "dogs"},
      %Video{id: "2", title: "cats"},
    ]

    content = render_to_string(VideoView, "index.html", conn: conn, videos: videos)

    assert String.contains?(content, "Listing videos")
    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Video.changeset(%Video{})
    categories = [{"cats", 123}]

    content = render_to_string(VideoView, "new.html",
      conn: conn,
      changeset: changeset,
      categories: categories
    )

    assert String.contains?(content, "New video")
    assert String.contains?(content, "Choose a category")
  end
end
