defmodule NabnakWeb.BoardLive do
  use NabnakWeb, :live_view
  use Phoenix.Component

  alias Nabnak.Tickets
  alias Nabnak.Tickets.Ticket
  alias Nabnak.Projects
  alias Nabnak.Accounts

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Nabnak.PubSub, "tickets")
    end

    # Get all projects and ensure we have a valid current project
    projects = Projects.list_projects()
    current_project = List.first(projects)

    # Get users
    # TODO: Only get users for this project
    users = Accounts.list_users()

    socket =
      socket
      |> assign(:projects, projects)
      |> assign(:current_project, current_project)
      |> assign(:users, users)
      |> assign_tickets()
      |> assign(:show_new_ticket_modal, false)
      |> assign(:changeset, Ticket.changeset(%Ticket{}, %{}))

    {:ok, socket}
  end

  @impl true
  def handle_event("new_ticket", _params, socket) do
    {:noreply, assign(socket, :show_new_ticket_modal, true)}
  end

  @impl true
  def handle_event("close_new_ticket", _params, socket) do
    {:noreply, assign(socket, :show_new_ticket_modal, false)}
  end

  @impl true
  def handle_event("save_ticket", %{"ticket" => ticket_params}, socket) do
    case socket.assigns.current_project do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "No project selected")
         |> assign(:changeset, Ticket.changeset(%Ticket{}, ticket_params))}

      project ->
        ticket_params =
          ticket_params
          |> Map.put("project_id", project.id)
          |> Map.put("status", "todo")

        case Tickets.create_ticket(ticket_params) do
          {:ok, _ticket} ->
            {:noreply,
             socket
             |> put_flash(:info, "Ticket created successfully")
             |> assign(:show_new_ticket_modal, false)
             |> assign_tickets()}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Error creating ticket")
             |> assign(:changeset, changeset)}
        end
    end
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
