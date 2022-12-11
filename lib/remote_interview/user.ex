defmodule RemoteInterview.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias RemoteInterview.Repo

  schema "users" do
    field :points, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_required([:points])
    |> validate_number(:points, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  def where_points_above(queryable, min_points) do
    from([u] in queryable, where: u.points > ^min_points)
  end

  def with_random_order(queryable) do
    order_by(queryable, fragment("RANDOM()"))
  end

  def with_limit(queryable, number) do
    limit(queryable, ^number)
  end

  def randomize_points do
    # q = from([u] in __MODULE__)
    # stream = Repo.stream(q)

    # Task.async_stream(stream, fn ->
    #   require IEx
    #   IEx.pry()
    # end)

    # Repo.transaction(fn ->
    #   tasks =
    #     stream
    #     |> Enum.chunk_every(1000)
    #     |> Enum.map(fn chunk ->
    #       Task.async(fn ->
    #         q = from(u in __MODULE__, update: [set: [points: fragment("FLOOR(RANDOM() * 100)")]])
    #         Repo.update_all(q, [])
    #       end)

    #       # Enum.map(chunk, fn u ->
    #       #   Task.async(fn ->
    #       #     u |> __MODULE__.changeset(%{points: :rand.uniform(100)}) |> Repo.update()
    #       #   end)
    #       # end)
    #     end)

    #   Task.await_many(tasks)
    # end)

    # tasks = Enum.map(1..10_000, fn _n ->
    # Repo.stream()
    # end)
    # Task.await_many(tasks)
    # TODO: Would like to find a way to optimize this.
    #       In theory, we could split the table into batches and update them in chunks
    query = from(u in __MODULE__, update: [set: [points: fragment("FLOOR(RANDOM() * 100)")]])
    Repo.update_all(query, [], timeout: 60_000)
  end
end
