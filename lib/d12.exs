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
    walk(goal, start, map)
  end

  def add_path_if_ok(paths, map, [current|_] = path, next, reached) do
    if next in reached do
      # No point in reaching a point now that was reached using
      # a shorter path already.
      paths
    else
      current_height = Map.get(map, current)
      case Map.get(map, next) do
        nil -> paths
        too_high when too_high > current_height + 1 -> paths
        _height ->
          [[next|path]|paths]
      end
    end
  end

  def bfs(map, start, goal) do
    Enum.reduce(1..10, {[[start]], MapSet.new |> MapSet.put(start)}, fn _ix, acc ->
      bfs_impl(acc, map, goal)
    end)
  end

  def bfs_impl({paths, reached}, map, goal) do
    paths2 = Enum.reduce(paths, [], fn [current|_] = path, acc ->
      acc
      |> add_path_if_ok(map, path, up(current), reached)
      |> add_path_if_ok(map, path, down(current), reached)
      |> add_path_if_ok(map, path, left(current), reached)
      |> add_path_if_ok(map, path, right(current), reached)
    end)
    |> Enum.sort(fn [lfirst|_], [rfirst|_] ->
      map[lfirst] >= map[rfirst]
    end)
    reached2 = Enum.reduce(paths2, reached, fn [first|_], acc ->
      MapSet.put(acc, first)
    end)
    {paths2, reached2}
  end
end
