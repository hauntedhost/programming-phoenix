defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase
  alias Rumbl.Video

  @valid_attrs %{url: "http://youtu.be", title: "cats", description: "meow"}
  @invalid_attrs %{title: "nope"}

  setup(%{conn: conn} = config) do
    if username = config[:login_as] do
      user = insert_user(%{username: username})
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn}
    else
      :ok
    end
  end

  defp video_count(query) do
    Repo.one from v in query, select: count(v.id)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123")),
    ], fn(conn) ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "batman"
  test "lists all current user videos on index", %{conn: conn} do
    user = conn.assigns.current_user
    user_video = insert_video(user, %{title: "hilarious cats"})
    other_video = insert_video(insert_user(), title: "other video")

    conn = get(conn, video_path(conn, :index))
    assert html_response(conn, 200) =~ ~r/listing videos/i
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  @tag login_as: "batman"
  test "creates current user video and redirects", %{conn: conn} do
    before_count = video_count(Video)
    user = conn.assigns.current_user
    conn = post(conn, video_path(conn, :create), video: @valid_attrs)
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
    assert video_count(Video) == before_count + 1
  end

  @tag login_as: "batman"
  test "given invalid params, does not create video, renders errors", %{conn: conn} do
    before_count = video_count(Video)
    conn = post(conn, video_path(conn, :create), video: @invalid_attrs)
    assert html_response(conn, 200) =~ ~r/please check the errors below/i
    assert video_count(Video) == before_count
  end

  @tag login_as: "batman"
  test "[PENDING] authorizes actions for current user video", %{conn: conn} do
    # show
    # edit
    # update with valid
    # update with invalid
    # delete
  end

  @tag login_as: "batman"
  test "rejects actions against other user video", %{conn: conn} do
    other_user = insert_user(%{username: "robin"})
    other_video = insert_video(other_user, %{title: "private to robin"})

    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :show, other_video))
    end

    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :edit, other_video))
    end

    assert_error_sent :not_found, fn ->
      put(conn, video_path(conn, :update, other_video, video: @valid_attrs))
    end

    assert_error_sent :not_found, fn ->
      delete(conn, video_path(conn, :update, other_video))
    end
  end
end
