defmodule Monado.Repo do
  use Ecto.Repo,
    otp_app: :monado,
    adapter: Ecto.Adapters.Postgres
end
