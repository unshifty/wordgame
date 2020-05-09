defmodule Wordplay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WordplayWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Wordplay.PubSub},
      WordplayWeb.Presence,
      # Start the Endpoint (http/https)
      WordplayWeb.Endpoint
      # Start a worker by calling: Wordplay.Worker.start_link(arg)
      # {Wordplay.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wordplay.Supervisor]
    ret = Supervisor.start_link(children, opts)
    Logger.info("Started #{__MODULE__}")
    ret
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WordplayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
