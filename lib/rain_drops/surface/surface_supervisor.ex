defmodule RainDrops.Surface.SurfaceSupervisor do
  use GenServer

  @registry RainDrops.SurfaceRegistry

  def init(init_arg) do
    {:ok, %{}}
  end

  def start_link(_args \\ []) do
    start = GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    start
  end

  def create_surface_cell(x, y) do
    RainDrops.Surface.SurfaceCell.start_link({x, y})
  end

  def get_surface(x, y) do
    case Registry.lookup(@registry, {:surface_cell, x, y}) do
      [{pid, _}] -> {:ok, pid}
      [] -> {}
    end
  end
end
