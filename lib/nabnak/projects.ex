defmodule Nabnak.Projects do
  import Ecto.Query
  alias Nabnak.Repo
  alias Nabnak.Projects.Project

  def list_projects do
    Repo.all(Project)
  end

  def get_project!(id) do
    Repo.get!(Project, id)
  end

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end
end
