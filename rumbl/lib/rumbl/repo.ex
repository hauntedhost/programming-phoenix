defmodule Rumbl.Repo do
  # use Ecto.Repo, otp_app: :rumbl

  def all(Rumbl.User) do
    [
      %Rumbl.User{id: "1", name: "Sean Omlor", username: "sean", password: "123"},
      %Rumbl.User{id: "2", name: "Alli Omlor", username: "alli", password: "123"},
      %Rumbl.User{id: "3", name: "Sebastian Pants", username: "sebastian", password: "123"},
    ]
  end

  def all(_) do
    []
  end

  def get(module, id) do
    Enum.find(all(module), fn(map) -> map.id == id end)
  end

  def get_by(module, params) do
    Enum.find(all(module), fn(map) ->
      Enum.all?(params, fn({key, val}) ->
        Map.get(map, key) == val
      end)
    end)
  end
end
