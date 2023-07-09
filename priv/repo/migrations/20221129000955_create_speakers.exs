defmodule Atomic.Repo.Migrations.CreateSpeakers do
  use Ecto.Migration

  def change do
    create table(:speakers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :bio, :text

      timestamps()
    end
  end
end