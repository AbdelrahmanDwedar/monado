defmodule Monado.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MonadoWeb.Telemetry,
      # Start the Ecto repository
      Monado.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Monado.PubSub},
      # Start Finch
      {Finch, name: Monado.Finch},
      # Start the Endpoint (http/https)
      MonadoWeb.Endpoint
      # Start a worker by calling: Monado.Worker.start_link(arg)
      # {Monado.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Monado.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MonadoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
