defmodule RemoteInterview.Benchmarks do
  alias RemoteInterview.User

  def run do
    Benchee.run(%{
      "async" => fn -> User.randomize_points_async() end,
      "update_all" => fn -> User.randomize_points_update_all() end
    }, time: 60)
  end
end
