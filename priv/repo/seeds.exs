# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RemoteInterview.Repo.insert!(%RemoteInterview.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias RemoteInterview.{Repo, User}

users_to_create = 1_000_000

1..users_to_create
|> Enum.chunk_every(10_000)
|> Enum.each(fn chunk ->
  users =
    Enum.map(chunk, fn _n ->
      datetime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      %{points: 0, inserted_at: datetime, updated_at: datetime}
    end)

  Repo.insert_all(User, users)
end)
