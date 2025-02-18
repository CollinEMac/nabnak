defmodule Nabnak.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :title, :string
      add :description, :text
      add :status, :string
      add :priority, :string
      add :project_id, references(:projects, on_delete: :nothing)
      add :assignee_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tickets, [:project_id])
    create index(:tickets, [:assignee_id])
  end
end
