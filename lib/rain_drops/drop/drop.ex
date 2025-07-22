defmodule RainDrops.Drop do
  use GenServer

  defstruct [:id, :x, :y, :delta_x, :delta_y]

  @refresh_rate_ms 200

  def start_link(%__MODULE__{} = init_state) do
    GenServer.start_link(__MODULE__, init_state)
  end

  def init(%__MODULE__{} = state) do
    schedule_refresh()
    {:ok, state}
  end

  def handle_info(:fall, state) do
    new_state = apply_delta(state)
    handle_position_surface(RainDrops.Surface.SurfaceSupervisor.get_surface(new_state.x , new_state.y), new_state)
    {:noreply, new_state}
  end

  defp handle_position_surface({}, state) do
    schedule_refresh()
    {:noreply, state}
  end

  defp handle_position_surface({_, pid}, state) do
    GenServer.cast(pid, {:drop_touched})
    Phoenix.PubSub.broadcast(RainDrops.PubSub, "raindrops", {:drop_removed, state.id})
     IO.puts("drop hit the surface at x: #{state.x} y: #{state.y}")
    {:noreply, state}
  end

  defp apply_delta(%__MODULE__{} = state) do

     s = %__MODULE__{state | x: state.x + state.delta_x, y: state.y + state.delta_y, }
     Phoenix.PubSub.broadcast(RainDrops.PubSub, "raindrops", {:drop_moved, state.id, s.x, s.y})
     s
  end

  defp schedule_refresh() do
    Process.send_after(self(), :fall, @refresh_rate_ms)
  end

end
