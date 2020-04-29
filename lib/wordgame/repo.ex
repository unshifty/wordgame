defmodule Wordgame.Repo do
  use Ecto.Repo,
    otp_app: :wordgame,
    adapter: Ecto.Adapters.Postgres
end
