defmodule Rumbl.Schema do
  import Ecto.Query, only: [from: 2]
  alias Rumbl.Repo
  alias GraphQL.Schema
  alias GraphQL.Type.ObjectType
  alias GraphQL.Type.List
  alias GraphQL.Type.String
  alias GraphQL.Type.ID

  def schema do
    video = %ObjectType{
      name: "Video",
      fields: %{
        id: %{type: %String{}},
        url: %{type: %String{}},
        title: %{type: %String{}},
      }
    }

    user = %ObjectType{
      name: "User",
      fields: %{
        id: %{type: %String{}},
        username: %{type: %String{}},
        name: %{type: %String{}},
        videos: %{
          type: %List{ofType: video},
          resolve: {Rumbl.Schema, :videos}
        },
      }
    }

    user_query = %{
      type: user,
      args: %{
        id: %{type: %String{}},
        username: %{type: %String{}}
      },
      resolve: {Rumbl.Schema, :user}
    }

    users_query = %{
      type: %List{ofType: user},
      resolve: {Rumbl.Schema, :users}
    }

    queries = %ObjectType{
      name: "GraphQL queries",
      fields: %{
        user: user_query,
        users: users_query
      }
    }

    %Schema{
      query: queries
    }
  end

  def user(_, params = %{id: user_id}, query) do
    Repo.get_by_uuid(Rumbl.User, user_id)
  end

  def user(_, params = %{username: username}, query) do
    Repo.one from v in Rumbl.User,
      where: v.username == ^username
  end

  def users(_, _, _) do
    Rumbl.Repo.all(Rumbl.User)
  end

  def videos(user = %Rumbl.User{}, _, _) do
    Repo.all from v in Rumbl.Video,
      where: v.user_id == ^user.id
  end
end
