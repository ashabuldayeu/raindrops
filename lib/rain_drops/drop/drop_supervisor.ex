defmodule RainDrops.Drop.DropSupervisor do
  alias RainDrops.Drop
  use GenServer

  @gen_interval_ms 2000
  defstruct [:count]
  def init(init_arg) do
    schedule_refresh()
    {:ok, %__MODULE__{count: 0}}
  end

  def start_link(_args \\ []) do
    start = GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    start
  end

  def handle_info(:gen_new, %__MODULE__{} = state) do
    spawn_drop()
    schedule_refresh()
    {:noreply, %__MODULE__{state | count: state.count + 1 }}
  end

  defp spawn_drop() do
    x = :rand.uniform(19)
    y = :rand.uniform(3)
    rnid = :rand.uniform(1000000)
    RainDrops.Drop.start_link(%Drop{id: rnid, x: x, y: y, delta_x: 0, delta_y: 1})

  end

  defp schedule_refresh() do
    Process.send_after(self(), :gen_new, @gen_interval_ms)
  end
end
