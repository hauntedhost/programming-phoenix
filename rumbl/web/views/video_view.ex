defmodule Rumbl.VideoView do
  use Rumbl.Web, :view

  def category_name(%Rumbl.Category{name: name}) do
    {:safe, name}
  end

  def category_name(_) do
    {:safe, ""}
  end
end
