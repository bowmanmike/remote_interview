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
    query = from(u in __MODULE__, update: [set: [points: fragment("FLOOR(RANDOM() * 100)")]])
    Repo.update_all(query, [])
  end
end
