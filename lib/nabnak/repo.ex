defmodule Nabnak.Repo do
  use Ecto.Repo,
    otp_app: :nabnak,
    adapter: Ecto.Adapters.Postgres
end
