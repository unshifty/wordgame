defmodule Wordspy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WordspyWeb.Telemetry,
      {Registry, keys: :unique, name: Wordspy.GameRegistry},
      Wordspy.WordCache,
      Wordspy.GameSupervisor,
      # Start the PubSub system
      {Phoenix.PubSub, name: Wordspy.PubSub},
      WordspyWeb.Presence,
      # Start the Endpoint (http/https)
      WordspyWeb.Endpoint
      # Start a worker by calling: Wordspy.Worker.start_link(arg)
      # {Wordspy.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wordspy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WordspyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
