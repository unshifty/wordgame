defmodule WordplayWeb.Presence do
  use Phoenix.Presence,
    otp_app: :wordplay,
    pubsub_server: Wordplay.PubSub
end
