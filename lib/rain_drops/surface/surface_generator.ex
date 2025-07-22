defmodule RainDrops.Surface.SurfaceGenerator do

  def generate_map(start_x, end_x, min_y, max_y) do
    gen_map_internal(start_x, end_x, min_y, max_y, [])
  end

  defp gen_map_internal(x, x, min_y, max_y, acc) do
    acc
  end

  defp gen_map_internal(last_x, max_x, min_y, max_y, acc) do
    y = :rand.uniform(max_y - min_y + 1) + min_y - 1
    next_min_y = max(0, y - 1)
    gen_map_internal(last_x + 1, max_x, next_min_y, next_min_y + 1, [{last_x, y} | acc])
  end

end
