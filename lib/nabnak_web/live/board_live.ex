defmodule NabnakWeb.BoardLive do
  use NabnakWeb, :live_view
  alias Nabnak.Tickets
  alias Nabnak.Projects

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Nabnak.PubSub, "tickets")
    end

    socket =
      socket
      |> assign(:projects, Projects.list_projects())
      |> assign_tickets()

    {:ok, socket}
  end

  @impl true
  def handle_event("new_ticket", _params, socket) do
    # TODO: Implement new ticket modal
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"value" => search_term}, socket) do
    tickets = Tickets.search_tickets(search_term)
    {:noreply, assign_tickets(socket, tickets)}
  end

  @impl true
  def handle_event("update_ticket_status", %{"ticket_id" => ticket_id, "status" => status}, socket) do
    ticket_id = String.to_integer(ticket_id)
    
    case Tickets.update_ticket_status(ticket_id, status) do
      {:ok, _ticket} ->
        Phoenix.PubSub.broadcast(Nabnak.PubSub, "tickets", {:ticket_updated})
        {:noreply, socket}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update ticket status")}
    end
  end

  @impl true
  def handle_info({:ticket_updated}, socket) do
    {:noreply, assign_tickets(socket)}
  end

  defp assign_tickets(socket, tickets \\ nil) do
    tickets = tickets || Tickets.list_tickets()
    
    socket
    |> assign(:todo_tickets, filter_tickets(tickets, "todo"))
    |> assign(:in_progress_tickets, filter_tickets(tickets, "in_progress"))
    |> assign(:review_tickets, filter_tickets(tickets, "review"))
    |> assign(:done_tickets, filter_tickets(tickets, "done"))
  end

  defp filter_tickets(tickets, status) do
    Enum.filter(tickets, & &1.status == status)
  end

  defp priority_color(priority) do
    case priority do
      "high" -> "bg-red-100 text-red-800"
      "medium" -> "bg-yellow-100 text-yellow-800"
      "low" -> "bg-green-100 text-green-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end
