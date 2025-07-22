defmodule RainDropsWeb.SimulationLive do
  use RainDropsWeb, :live_view
  @registry RainDrops.SurfaceRegistry

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(RainDrops.PubSub, "raindrops")
      |> IO.inspect(label: "liveview bus subscribed")
    end

    map = RainDrops.Surface.SurfaceGenerator.generate_map(0, 20, 15, 20)

    Enum.each(map, fn {x, y} ->
      # IO.puts("Cell: x:#{x}  y:#{y}")
      RainDrops.Surface.SurfaceSupervisor.create_surface_cell(x, y)
    end)

    {:ok, assign(socket, drops: %{}, surface:  Map.new(map, fn {x, y} -> {{x, y}, true} end))}
  end

  @impl true
def terminate(_reason, socket) do
  IO.puts("💀 LiveView terminate: cleaning up surface cells...")

  Enum.each(socket.assigns.surface, fn {{x, y}, _value} ->
    IO.puts("🔍 Deleting surface cell at (#{x}, #{y})")

    case RainDrops.Surface.SurfaceSupervisor.get_surface(x, y) do
      {:ok, pid} when is_pid(pid) ->
        IO.puts("☠️ Killing PID: #{inspect(pid)}")
        Process.exit(pid, :normal)
        {:ok, ppid} = RainDrops.Surface.SurfaceSupervisor.get_surface(x, y)
        IO.puts("found result #{ppid}")
      _ ->
        IO.puts("⚠️ Surface cell not found at (#{x}, #{y})")
    end
  end)

  :ok
end

  def handle_info({:drop_created, %{id: id, x: x, y: y}}, socket) do
    drops = Map.put(socket.assigns.drops, id, %{x: x, y: y})
    {:noreply, assign(socket, drops: drops)}
  end

  def handle_info({:drop_moved, id, x, y}, socket) do
    new_drops = Map.update(socket.assigns.drops, id, %{x: x, y: y}, fn drop ->
      Map.put(drop, :x, x) |> Map.put(:y, y)
    end)
    # IO.puts("#{}")
    {:noreply, assign(socket, drops: new_drops)}
  end


  def handle_info( {:drop_removed, id}, socket) do
    new_drops = Map.delete(socket.assigns.drops, id)
    # IO.puts("#{}")
    {:noreply, assign(socket, drops: new_drops)}
  end


  def handle_info({:surface_cell_created, %{x: x, y: y}}, socket) do
    IO.puts("cell created at x: #{x} y: #{y}")
    surface = Map.put(socket.assigns.surface, {x, y}, true)
    {:noreply, assign(socket, surface: surface)}
  end

  def handle_info(s, socket) do
    # drops = Map.put(socket.assigns.drops, id, %{x: x, y: y})
     {:noreply, assign(socket, drops: socket.assigns.drops)}
  end
  def render(assigns) do
    ~H"""
    <div style="position: relative; width: 400px; height: 400px; border: 1px solid #ccc; background: #eef;">
      <div id="drops" phx-update="replace">
        <%= for {id, %{x: x, y: y}} <- @drops do %>
          <div id={"drop-#{id}"} style={"position:absolute; left:#{x * 20}px; top:#{y * 20}px; width: 20px; height: 20px;"}>
           💧
          </div>
        <% end %>
      </div>

      <div id="surface" phx-update="ignore">
        <%= for {x, y} <- Map.keys(@surface) do %>
          <div id={"surface-#{x}-#{y}"} style={
          "position: absolute; left: #{x * 20}px; top: #{y * 20}px; width: 20px; height: 20px; background: #666;"
        }>
            🪨
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
