defmodule Rumbl.TestHelpers do
  alias Rumbl.Repo

  def insert_user(attrs \\ %{}) do
    # NOTE: even though Dict is deprecated, getting intermittent errors with
    # this function when using Map.merge
    changes = Dict.merge(%{
      name: "Example User",
      username: "user-#{random_hash}",
      password: "supersecret"
    }, attrs)

    %Rumbl.User{}
    |> Rumbl.User.registration_changeset(changes)
    |> Repo.insert!
  end

  def insert_video(user, attrs \\ %{}) do
    changeset = Ecto.build_assoc(user, :videos, attrs)
    Rumbl.Repo.insert!(changeset)
  end

  defp random_hash do
    Base.encode16(:crypto.rand_bytes(8))
    |> String.downcase
  end
end
