defmodule D12 do
  def demo_input() do
    ~S"""
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """ |> String.trim
  end

  def input(), do: File.read!("data/d12")

  def parse(input) do
    lines = String.split(input, "\n") |> Enum.map(&(to_charlist(&1)))
    {_, _, s, e, m} = Enum.reduce(lines, {0, 0, nil, nil, %{}}, fn line, {x, y, s, e, m} = acc ->
      {x, y, s, e, m} = Enum.reduce(line, acc, fn char, {x, y, s, e, m} = acc ->
        {s, e, char} = case char do
          ?S -> {{x,y}, e, ?a}
          ?E -> {s, {x,y}, ?z}
          _ -> {s, e, char}
        end
        m = Map.put(m, {x,y}, char - ?a)
        {x+1, y, s, e, m}
      end)
      {0, y+1, s, e, m}
    end)
    {s, e, m}
  end

  def up({x,y}), do: {x,y-1}
  def down({x,y}), do: {x,y+1}
  def left({x,y}), do: {x-1,y}
  def right({x,y}), do: {x+1,y}

  def p1() do
    {start, goal, map} = input |> parse
    bfs(map, start, goal)
  end

  def add_path_if_ok(reached, map, current, next, :walk_up) do
    if next in reached do
      # No point in reaching a point now that was reached using
      # a shorter path already.
      #IO.inspect "Not adding path; already reached"
      reached
    else
      current_height = Map.get(map, current)
      case Map.get(map, next) do
        nil ->
          #IO.inspect "Not adding path; outside of map"
          reached
        too_high when too_high > current_height + 1 ->
          #IO.inspect "Not adding path; too high"
          reached
        _height ->
          #IO.inspect "Adding to path"
          MapSet.put(reached, next)
      end
    end
  end

  def add_path_if_ok(reached, map, current, next, :walk_down) do
    if next in reached do
      # No point in reaching a point now that was reached using
      # a shorter path already.
      #IO.inspect "Not adding path; already reached"
      reached
    else
      current_height = Map.get(map, current)
      case Map.get(map, next) do
        nil ->
          #IO.inspect "Not adding path; outside of map"
          reached
        too_low when too_low < current_height - 1 ->
          #IO.inspect "Not adding path; too high"
          reached
        _height ->
          #IO.inspect "Adding to path"
          MapSet.put(reached, next)
      end
    end
  end

  def bfs(map, start, goal) do
    bfs_impl(MapSet.new |> MapSet.put(start), 1, map, goal)
  end

  def bfs_impl(reached, iterations, map, goal) do
    IO.inspect "Length is #{iterations}"
    reached = bfs_step(reached, map, goal, :walk_up)
    if goal in reached do
      iterations
    else
      bfs_impl(reached, iterations + 1, map, goal)
    end
  end

  def bfs_step(previously_reached, map, _goal, walk_direction) do
    Enum.reduce(previously_reached, previously_reached, fn current, acc ->
      acc
      |> add_path_if_ok(map, current, up(current), walk_direction)
      |> add_path_if_ok(map, current, down(current), walk_direction)
      |> add_path_if_ok(map, current, left(current), walk_direction)
      |> add_path_if_ok(map, current, right(current), walk_direction)
    end)
  end

  def bfs_impl_goal_height(reached, iterations, map, goal_height) do
    IO.inspect "Length is #{iterations}"
    reached = bfs_step(reached, map, 0, :walk_down)
    reached_at_goal_height = Enum.filter(reached, fn coord -> map[coord] == goal_height end)
    if [] != reached_at_goal_height do
      iterations
    else
      bfs_impl_goal_height(reached, iterations + 1, map, goal_height)
    end
  end

  def p2() do
    {start, goal, map} = input |> parse
    bfs_impl_goal_height(MapSet.new |> MapSet.put(goal), 1, map, 0)
  end
end
