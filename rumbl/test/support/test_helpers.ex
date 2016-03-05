defmodule Rumbl.TestHelpers do
  alias Rumbl.Repo
  alias Rumbl.User

  def insert_user(attrs \\ %{}) do
    params = Map.merge(%{
      name: "Example User",
      username: "user-#{random_hash}",
      password: "supersecret"
    }, attrs)

    changeset = User.registration_changeset(%User{}, params)
    Repo.insert!(changeset)
  end

  def insert_video(user, attrs \\ %{}) do
    changeset = Ecto.build_assoc(user, :videos, attrs)
    Repo.insert!(changeset)
  end

  defp secret_key_base do
    Application.get_env(:rumbl, Rumbl.Endpoint)[:secret_key_base]
  end

  defp random_hash do
    Base.encode16(:crypto.rand_bytes(8))
    |> String.downcase
  end
end
