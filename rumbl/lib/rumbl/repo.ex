defmodule Rumbl.Repo do
  use Ecto.Repo, otp_app: :rumbl
  import Ecto.Query, only: [from: 2, order_by: 3]

  def get_first(query) do
    one from r in query,
      order_by: [asc: r.inserted_at],
      limit: 1
  end

  def get_last(query) do
    one from r in query,
      order_by: [desc: r.inserted_at],
      limit: 1
  end

  def get_by_uuid!(model, id) do
    case Ecto.Type.dump(Ecto.UUID, id) do
      {:ok, _} ->
        get!(model, id)
      :error ->
        raise Ecto.NoResultsError, queryable: model
    end
  end
end
