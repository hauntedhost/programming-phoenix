defmodule Rumbl.Category do
  use Rumbl.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "categories" do
    field :name, :string
    has_many :videos, Rumbl.Video

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def alphabetical(query) do
    from c in query, order_by: c.name
  end

  def names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end
end
