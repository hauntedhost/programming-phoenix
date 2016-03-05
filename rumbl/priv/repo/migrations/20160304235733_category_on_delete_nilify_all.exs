defmodule Rumbl.Repo.Migrations.CategoryOnDeleteNilifyAll do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE videos DROP CONSTRAINT videos_category_id_fkey"
    alter table(:videos) do
      modify :category_id, references(:categories, type: :binary_id, on_delete: :nilify_all)
    end
  end

  def down do
    execute "ALTER TABLE videos DROP CONSTRAINT videos_category_id_fkey"
    alter table(:videos) do
      modify :category_id, references(:categories, type: :binary_id, on_delete: :nothing)
    end
  end
end
