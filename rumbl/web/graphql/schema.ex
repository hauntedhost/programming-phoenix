defmodule Rumbl.Schema do
  import Ecto.Query, only: [from: 2]
  alias Rumbl.Repo
  alias GraphQL.Schema
  alias GraphQL.Type.ObjectType
  alias GraphQL.Type.List
  alias GraphQL.Type.String
  alias GraphQL.Type.ID

  @moduledoc """
  This module configures the Rumbl GraphQL implementation.

  example queries:
  {
    user(username:"sean") {
      name
    }

    user(id: "63254a3f-76fa-469a-9132-7224ffcbb9b1") {
      username
    }

    users {
      id,
      name,
      videos(category: "elixir") {
        title,
        user {
          id,
          name
        }
      }
    }

    video(id: "6076fed9-d2d0-43d3-965c-077359a65638") {
      id,
      title
    }

    videos {
      title
    }

    categories {
      id,
      name
    }
  }
  """

  def schema do
    %Schema{
      query: %ObjectType{
        name: "API",
        fields: %{
          user: user_query,
          users: users_query,
          video: video_query,
          videos: videos_query,
          categories: categories_query
        }
      }
    }
  end

  # QUERIES
  # -------

  defp user_query do
    %{
      type: user_type,
      args: %{
        id: %{type: %String{}},
        username: %{type: %String{}}
      },
      resolve: {Rumbl.Schema, :user}
    }
  end

  defp users_query do
    %{
      type: %List{ofType: user_type},
      resolve: {Rumbl.Schema, :users}
    }
  end


  defp video_query do
    %{
      type: video_type,
      args: %{
        id: %{type: %String{}}
      },
      resolve: {Rumbl.Schema, :video}
    }
  end

  defp videos_query do
    %{
      type: %List{ofType: video_type},
      args: %{
        category: %{type: %String{}}
      },
      resolve: {Rumbl.Schema, :videos}
    }
  end

  defp categories_query do
    %{
      type: %List{ofType: category_type},
      resolve: {Rumbl.Schema, :categories}
    }
  end

  # TYPES
  # -----

  defp user_type do
    %ObjectType{
      name: "User",
      fields: %{
        id: %{type: %String{}},
        username: %{type: %String{}},
        name: %{type: %String{}},
        videos: %{
          args: %{
            category: %{type: %String{}}
          },
          type: %List{ofType: video_type},
          resolve: {Rumbl.Schema, :videos}
        },
      }
    }
  end

  defp video_type do
    %ObjectType{
      name: "Video",
      fields: %{
        id: %{type: %String{}},
        url: %{type: %String{}},
        title: %{type: %String{}},
        user: %{
          type: video_user_type,
          resolve: {Rumbl.Schema, :user}
        },
        category: %{
          type: %String{},
          resolve: {Rumbl.Schema, :category}
        },
      }
    }
  end

  defp video_user_type do
    %ObjectType{
      name: "User",
      fields: %{
        id: %{type: %String{}},
        username: %{type: %String{}},
        name: %{type: %String{}}
      }
    }
  end

  defp category_type do
    %ObjectType{
      name: "Category",
      fields: %{
        id: %{type: %String{}},
        name: %{type: %String{}},
      }
    }
  end

  # RESOLVERS
  # ---------

  def users(_, _, _) do
    Rumbl.Repo.all(Rumbl.User)
  end

  def user(video = %Rumbl.Video{}, _, _) do
    Repo.one Ecto.assoc(video, :user)
  end

  def user(_, %{id: user_id}, _) do
    Repo.get_by_uuid(Rumbl.User, user_id)
  end

  def user(_, %{username: username}, _) do
    Repo.one from u in Rumbl.User,
      where: ilike(u.username, ^username)
  end

  def videos(user = %Rumbl.User{}, %{category: category}, _) do
    Repo.all from v in Ecto.assoc(user, :videos),
      join: c in assoc(v, :category),
      where: ilike(c.name, ^category)
  end

  def videos(user = %Rumbl.User{}, _, _) do
    Repo.all Ecto.assoc(user, :videos)
  end

  def videos(_, %{category: category}, _) do
    Repo.all from v in Rumbl.Video,
      join: c in assoc(v, :category),
      where: ilike(c.name, ^category)
  end

  def videos(_, _, _) do
    Repo.all(Rumbl.Video)
  end

  def video(_, %{id: video_id}, _) do
    Repo.get_by_uuid(Rumbl.Video, video_id)
  end

  def categories(_, _, _) do
    Repo.all(Rumbl.Category)
  end

  def category(video = %Rumbl.Video{}, _, _) do
    Repo.one from c in Ecto.assoc(video, :category),
      select: c.name
  end
end
