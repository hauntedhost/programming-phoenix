defmodule Rumbl.VideoController do
  use Rumbl.Web, :controller
  alias Rumbl.Video
  plug :scrub_params, "video" when action in [:create, :update]

  # def action(conn, _) do
  #   current_user = conn.assigns.current_user
  #   apply(__MODULE__, action_name(conn), [conn, conn.params, current_user])
  # end

  def index(conn, _params) do
    videos = user_videos(conn) |> Repo.all
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params) do
    changeset = Video.changeset(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    changeset = current_user(conn)
    |> build_assoc(:videos)
    |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    video = get_from_user_videos!(conn, id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}) do
    video = get_from_user_videos!(conn, id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}) do
    video = get_from_user_videos!(conn, id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    video = get_from_user_videos!(conn, id)
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  defp user_videos(conn) do
    assoc(current_user(conn), :videos)
  end

  defp get_from_user_videos!(conn, id) do
    Repo.get_by_uuid!(user_videos(conn), id)
  end
end
