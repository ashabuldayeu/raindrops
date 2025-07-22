defmodule RainDrops.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: RainDrops.PubSub},
      {Registry, keys: :unique, name: RainDrops.SurfaceRegistry},
      RainDrops.Drop.DropSupervisor,
      RainDrops.Surface.SurfaceSupervisor,
      RainDropsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:rain_drops, :dns_cluster_query) || :ignore},
      # {Phoenix.PubSub, name: RainDrops.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RainDrops.Finch},
      # Start a worker by calling: RainDrops.Worker.start_link(arg)
      # {RainDrops.Worker, arg},
      # Start to serve requests, typically the last entry
      RainDropsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RainDrops.Supervisor]
    proc = Supervisor.start_link(children, opts)

    # map = RainDrops.Surface.SurfaceGenerator.generate_map(0, 20, 5, 10)

    # Enum.each(map, fn {x, y} ->
    #   # IO.puts("Cell: x:#{x}  y:#{y}")
    #   RainDrops.Surface.SurfaceSupervisor.create_surface_cell(x, y)
    # end)

    IO.puts("app started")
    proc

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RainDropsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
