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

  # This is a reverse walk from the goal to the start as that
  # eliminates possibilities more quickly (I think).
  def walk(current, goal, map, num_steps \\ 0, prev_height \\ 0, visited \\ [])
  def walk(current, goal, map, num_steps, prev_height, visited) do
    if current in visited do
      999999999999
    else
      if current == goal and map[current] >= prev_height - 1 do
        num_steps
      else
        case map[current] do
          too_low when too_low < prev_height - 1 ->
            999999999999
          nil ->
            999999999999
          height ->
            new_visited = [current|visited]
            new_steps = num_steps + 1
            [
              walk(up(current), goal, map, new_steps, height, new_visited),
              walk(down(current), goal, map, new_steps, height, new_visited),
              walk(left(current), goal, map, new_steps, height, new_visited),
              walk(right(current), goal, map, new_steps, height, new_visited),
            ]
            |> Enum.sort()
            |> Enum.at(0)
        end
      end
    end
  end

  def p1() do
    {start, goal, map} = input |> parse
    bfs(map, start, goal)
  end

  def add_path_if_ok(reached, map, current, next) do
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

  def bfs(map, start, goal) do
    bfs_impl(MapSet.new |> MapSet.put(start), 1, map, goal)
  end

  def bfs_impl(reached, iterations, map, goal) do
    IO.inspect "Length is #{iterations}"
    reached = bfs_step(reached, map, goal)
    if goal in reached do
      iterations
    else
      bfs_impl(reached, iterations + 1, map, goal)
    end
  end

  def bfs_step(previously_reached, map, goal) do
    Enum.reduce(previously_reached, previously_reached, fn current, acc ->
      acc
      |> add_path_if_ok(map, current, up(current))
      |> add_path_if_ok(map, current, down(current))
      |> add_path_if_ok(map, current, left(current))
      |> add_path_if_ok(map, current, right(current))
    end)
  end
end
