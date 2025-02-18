defmodule Nabnak.Tickets do
  import Ecto.Query
  alias Nabnak.Repo
  alias Nabnak.Tickets.Ticket

  def list_tickets do
    Ticket
    |> preload([:assignee, :project])
    |> Repo.all()
  end

  def get_ticket!(id) do
    Ticket
    |> preload([:assignee, :project])
    |> Repo.get!(id)
  end

  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.changeset(attrs)
    |> Repo.insert()
  end

  def update_ticket_status(ticket_id, status) do
    get_ticket!(ticket_id)
    |> Ticket.changeset(%{status: status})
    |> Repo.update()
  end

  def search_tickets(search_term) do
    from(t in Ticket,
      where: ilike(t.title, ^"%#{search_term}%"),
      or_where: ilike(t.description, ^"%#{search_term}%"),
      preload: [:assignee, :project]
    )
    |> Repo.all()
  end
end
