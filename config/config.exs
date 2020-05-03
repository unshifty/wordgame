# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :wordplay, WordplayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jT0y8r6O+5hMuNZw+Ub04kJMwvZKBXZiUbYQhHddWeoXhcL+3uVn1Hm5Rxx89ibT",
  render_errors: [view: WordplayWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Wordplay.PubSub,
  live_view: [signing_salt: "PM/V3wTP"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
