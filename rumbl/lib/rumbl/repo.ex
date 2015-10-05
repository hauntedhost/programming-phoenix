defmodule Rumbl.Repo do
  # use Ecto.Repo, otp_app: :rumbl

  @moduledoc """
  In memory repository
  """

  def all(Rumbl.User) do
    [
      %Rumbl.User{id: "1", name: "Sean", username: "somlor", password: "elixir"},
      %Rumbl.User{id: "2", name: "Alli", username: "alli", password: "cookies"},
      %Rumbl.User{id: "3", name: "Sebastian", username: "sebastian", password: "meow"},
    ]
  end

  def all(_module), do: []

  def get(module, id) do
    all(module) |> Enum.find &(params_match?(&1, {:id, id}))
  end

  def get_by(module, params) do
    all(module) |> Enum.find &(all_params_match?(&1, params))
  end

  defp all_params_match?(record, params) do
    params |> Enum.all? &(params_match?(record, &1))
  end

  defp params_match?(record, {key, val}) do
    Map.get(record, key) == val
  end
end