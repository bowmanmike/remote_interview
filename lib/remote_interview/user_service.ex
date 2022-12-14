defmodule RemoteInterview.UserService do
  use GenServer

  alias RemoteInterview.{Repo, User}

  @one_minute 1000 * 60

  @impl true
  def init(state) do
    schedule_work()

    {:ok, state}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def show_users() do
    GenServer.call(__MODULE__, :show_users)
  end

  @impl true
  def handle_info(:update_number, state) do
    randomize_point_values()
    new_number = :rand.uniform(100)

    schedule_work()

    {:noreply, %{state | min_number: new_number}}
  end

  @impl true
  def handle_call(:show_users, _from, state) do
    users =
      User
      |> User.where_points_above(state.min_number)
      |> User.with_random_order()
      |> User.with_limit(2)
      |> Repo.all()

    new_timestamp = DateTime.utc_now()
    prev_timestamp = state.timestamp

    new_state = %{state | prev_timestamp: prev_timestamp, timestamp: new_timestamp}
    {:reply, %{users: users, timestamp: prev_timestamp}, new_state}
  end

  def default_state, do: %{min_number: 0, timestamp: nil, prev_timestamp: nil}

  def schedule_work, do: Process.send_after(self(), :update_number, @one_minute)

  defp randomize_point_values, do: User.randomize_points()
end
