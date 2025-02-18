defmodule Nabnak.Accounts do
  @moduledoc """
  The Accounts context handles all user-related operations.
  """
  
  import Ecto.Query
  alias Nabnak.Repo
  alias Nabnak.Accounts.User

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @doc """
  Gets a single user by email.

  Returns nil if the User does not exist.
  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{name: "John Doe", email: "john@example.com"})
      {:ok, %User{}}

      iex> create_user(%{email: nil})
      {:error, %Ecto.Changeset{}}
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns a list of users with their assigned tickets.
  """
  def list_users_with_tickets do
    User
    |> preload(:assigned_tickets)
    |> Repo.all()
  end

  @doc """
  Gets a user with their assigned tickets.
  """
  def get_user_with_tickets!(id) do
    User
    |> preload(:assigned_tickets)
    |> Repo.get!(id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
