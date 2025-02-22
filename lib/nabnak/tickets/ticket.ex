defmodule Nabnak.Tickets.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tickets" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "todo"
    field :priority, :string, default: "medium"
    
    belongs_to :project, Nabnak.Projects.Project
    belongs_to :assignee, Nabnak.Accounts.User

    timestamps()
  end

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:title, :description, :status, :priority, :project_id, :assignee_id])
    |> validate_required([:title, :status, :priority, :project_id])
    |> validate_inclusion(:status, ["todo", "in_progress", "review", "done"])
    |> validate_inclusion(:priority, ["low", "medium", "high"])
    |> foreign_key_constraint(:project_id) 
  end
end

