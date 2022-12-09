defmodule RemoteInterview.Repo do
  use Ecto.Repo,
    otp_app: :remote_interview,
    adapter: Ecto.Adapters.Postgres
end
