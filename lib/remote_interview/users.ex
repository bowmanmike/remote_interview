defmodule RemoteInterview.Users do
  alias RemoteInterview.{Repo, User}

  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
