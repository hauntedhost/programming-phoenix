defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "Batman", username: "batman"}

  test "converts unique_constraint on username to error" do
    insert_user(username: "batman")
    attrs = Map.put(@valid_attrs, :username, "batman")
    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, "has already been taken"} in changeset.errors
  end
end
