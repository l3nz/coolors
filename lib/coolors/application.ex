defmodule Coolors.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CoolorsWeb.Telemetry,
      Coolors.Repo,
      # Dynamic supervisor, one per room
      Coolors.Rooms,
      {DNSCluster, query: Application.get_env(:coolors, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Coolors.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Coolors.Finch},
      # Start a worker by calling: Coolors.Worker.start_link(arg)
      # {Coolors.Worker, arg},
      # Start to serve requests, typically the last entry
      CoolorsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coolors.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CoolorsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
