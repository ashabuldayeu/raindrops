defmodule RainDrops.Surface.SurfaceCell do
  use GenServer

  defstruct [:x, :y, :type]
  @registry RainDrops.SurfaceRegistry

  def start_link({x, y}) do
    name = via_tuple({x, y})
    GenServer.start_link(__MODULE__, %__MODULE__{x: x, y: y, type: :dry}, name: name)
  end

  def init(%__MODULE__{} = state) do
    {:ok, state}
  end

  def handle_cast({:drop_touched}, %__MODULE__{} = state) do
    new_state = change_type(state.type, state)
    {:noreply, new_state}
  end

  defp change_type(:dry, %__MODULE__{} = state) do
    %__MODULE__{state | type: :wet}
  end

  defp change_type(:wet, %__MODULE__{} = state) do
    %__MODULE__{state | type: :water}
  end

  defp change_type(:water, %__MODULE__{} = state) do
    %__MODULE__{state | type: :water}
  end

  defp via_tuple({x, y}) do
    {:via, Registry, {@registry, {:surface_cell, x, y}}}
end

end
