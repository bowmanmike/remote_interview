import_if_available(Ecto.Query)

alias RemoteInterview.{Repo, User, Users}

defmodule Utils do
  def count_query(schema), do: from(x in schema, select: count(x.id))
end
