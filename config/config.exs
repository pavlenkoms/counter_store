# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :counter_store, CounterStoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1DZrMsRScB1k5HYQNc6xz7rCTp2HZFx3o7xdHi1CrxSDWXh8mCSJijuU0yczC++h",
  render_errors: [view: CounterStoreWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CounterStore.PubSub,
  live_view: [signing_salt: "kMw4GpNS"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :libcluster,
  topologies: [
    gossip: [
      strategy: Elixir.Cluster.Strategy.Gossip,
      config: [
        port: 45892,
        if_addr: "0.0.0.0",
        multicast_addr: "255.255.255.255",
        broadcast_only: true
      ]
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
