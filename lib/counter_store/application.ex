defmodule CounterStore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      # Start the Telemetry supervisor
      CounterStoreWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CounterStore.PubSub},
      # Start the Endpoint (http/https)
      CounterStoreWeb.Endpoint,
      CounterStore.Storage,
      CounterStore.Bus,
      {Cluster.Supervisor, [topologies, [name: CounterStore.ClusterSupervisor]]}
      # Start a worker by calling: CounterStore.Worker.start_link(arg)
      # {CounterStore.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CounterStore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CounterStoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
