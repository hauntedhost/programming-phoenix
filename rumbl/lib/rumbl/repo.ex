defmodule Rumbl.Repo do
  use Ecto.Repo, otp_app: :rumbl

  def get_by_uuid!(model, id) do
    case Ecto.Type.dump(Ecto.UUID, id) do
      {:ok, _} ->
        get!(model, id)
      :error ->
        raise Ecto.NoResultsError, queryable: model
    end
  end
end
