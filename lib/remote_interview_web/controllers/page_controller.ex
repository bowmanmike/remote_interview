defmodule RemoteInterviewWeb.PageController do
  use RemoteInterviewWeb, :controller

  alias RemoteInterview.UserService

  def home(conn, _params) do
    %{timestamp: timestamp, users: users} = UserService.show_users()

    response = %{
      timestamp: timestamp,
      users: Enum.map(users, fn user -> %{id: user.id, points: user.points} end)
    }

    json(conn, response)
  end
end
