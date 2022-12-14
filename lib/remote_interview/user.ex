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

  def randomize_points(user = %__MODULE__{}) do
    user
    |> changeset(%{points: :rand.uniform(100)})
    |> Repo.update!()
  end

  def randomize_points, do: randomize_points_update_all()

  # NOTE: I'll leave this function here as evidence, or if future users
  #       want to do more benchmarking.
  def randomize_points_async do
    query = from(u in __MODULE__)
    stream = Repo.stream(query)

    Repo.transaction(
      fn ->
        stream
        |> Stream.chunk_every(200_000)
        |> Task.async_stream(
          fn chunk ->
            ids = Enum.map(chunk, fn user -> user.id end)
            now = DateTime.utc_now()

            q =
              from(u in __MODULE__,
                where: u.id in ^ids,
                update: [
                  set: [
                    points: fragment("FLOOR(RANDOM() * 100)"),
                    updated_at: ^now
                  ]
                ]
              )

            Repo.update_all(q, [])
          end,
          timeout: :infinity,
          max_concurrency: 100
        )
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  def randomize_points_update_all do
    updated_at = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    query =
      from(u in __MODULE__,
        update: [set: [points: fragment("FLOOR(RANDOM() * 100)"), updated_at: ^updated_at]]
      )

    Repo.update_all(query, [], timeout: 60_000)
  end
end
