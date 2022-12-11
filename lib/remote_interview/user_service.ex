defmodule RemoteInterview.UserService do
  use GenServer

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
    GenServer.cast(__MODULE__, :show_users)
  end

  @impl true
  def handle_info(:update_number, state) do
    schedule_work()
    new_number = :rand.uniform(100)

    {:noreply, %{state | min_number: new_number}}
  end

  @impl true
  def handle_cast(:show_users, state) do
    new_state = %{state | timestamp: DateTime.utc_now()}
    # grab 2 random users here

    {:noreply, new_state}
  end

  def default_state, do: %{min_number: 0, timestamp: nil}

  def schedule_work, do: Process.send_after(self(), :update_number, @one_minute)
end
