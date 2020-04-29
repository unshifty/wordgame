defmodule Wordgame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WordgameWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Wordgame.PubSub},
      # Start the Endpoint (http/https)
      WordgameWeb.Endpoint
      # Start a worker by calling: Wordgame.Worker.start_link(arg)
      # {Wordgame.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wordgame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WordgameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
