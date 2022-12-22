defmodule D16 do
  def demo_input() do
    ~S"""
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
    """ |> String.trim()
  end

  def input(), do: File.read!("data/d16")

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, valve, flow_rate, rest] = Regex.run(~r/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/, line)
      {flow_rate, ""} = Integer.parse(flow_rate)
      rest = String.split(rest, ", ")
      {valve, {flow_rate, rest}}
    end)
    |> Enum.into(%{})
  end

  # paths is list of {map, location, pressure_released}
  #$def bfs_step(paths, 30) do
  #  # Enum.sort_by(paths, &(&1 |> elem(2)), &>=/2) |> Enum.at(0) |> elem(2)
  # {paths, }
  #end
  def bfs_step(paths, minutes_remaining_at_end_of_move) do
    Enum.flat_map(paths, fn {map, location, pressure_released} ->
      {flow_rate, next_locations} = map[location]
      Enum.map(next_locations, fn next_loc ->
        {map, next_loc, pressure_released}
      end)
      ++
      [{Map.put(map, location, {0, next_locations}), location, pressure_released + minutes_remaining_at_end_of_move * flow_rate}]
    end)
    |> Enum.sort_by(&(&1 |> elem(2)), &>=/2)
    |> Enum.take(5000)
  end

  def bfs(map, num_steps \\ 30) do
    Enum.reduce(num_steps-1..0, [{map, "AA", 0}], fn min_remain, acc ->
      bfs_step(acc, min_remain)
    end)
    |> Enum.take(1)
  end

  # DFS approach with heuristics, which I abandoned.
  def walk(_, _, _, 30, pressure_released), do: pressure_released
  def walk(map, location, prev_location, minutes_passed, pressure_released) do
    IO.inspect {:walk, location, minutes_passed, pressure_released}
    minutes_remaining_after_opening_valve = 30 - minutes_passed - 1
    {flow_rate, next_locations} = map[location]
    new_flow_rate = case flow_rate do
      fr when fr <= 0 -> fr - 1
      _ -> 0
    end

    case new_flow_rate do
      -3 ->
        pressure_released  # Give up going in circles
      _ ->
        # another time, we decrease the flow rate by 1 every time.
        map = Map.put(map, location, {new_flow_rate, next_locations})

        # Open valve and then go to possible valves, or do not open
        # valve and then go to possible valves.
        #
        # No need to search the space where the pressure released by the valve is zero.
        Enum.flat_map(next_locations, fn loc ->
          [walk(map, loc, location, minutes_passed + 1, pressure_released)]
          ++
          case {flow_rate, minutes_remaining_after_opening_valve} do
            {0, _} -> []
            {_, 0} -> []
            _ ->
              [walk(map, location, location, minutes_passed + 1, pressure_released + flow_rate * minutes_remaining_after_opening_valve)]
          end
        end)
        |> Enum.sort(&>=/2)
        |> Enum.at(0)
  end
  end

  def p1() do
    map = input() |> parse()
    bfs(map)
  end

  def bfs2_step(paths, minutes_remaining_at_end_of_move) do
    # The my_path and el_path are just for debugging and could be removed.
    Enum.flat_map(paths, fn {map, my_location, el_location, my_path, el_path, pressure_released} ->
      {my_loc_flow_rate, my_next_locations} = map[my_location]
      {el_loc_flow_rate, el_next_locations} = map[el_location]

      # Now we get the following options:
      # - I open a valve, and the elephant opens a valve (if it's the same loc it's zero)
      # - I open a valve, the elephant goes to one of its next places
      # - The elephant opens a valve, I go to one of my next places
      # - Each of us goes to one of our next places (for each place I can go to, enum
      #   each place the elephant can go to)

      both_map = Map.put(map, my_location, {0, my_next_locations})
      {both_el_flow_rate, _} = both_map[el_location]
      both_map = Map.put(both_map, el_location, {0, el_next_locations})
      both_options = [{both_map, my_location, el_location, ["open"|my_path], ["open"|el_path],
        pressure_released + minutes_remaining_at_end_of_move * (my_loc_flow_rate + both_el_flow_rate)}]

      me_map = Map.put(map, my_location, {0, my_next_locations})
      me_options = Enum.map(el_next_locations, fn el_next ->
        {me_map, my_location, el_next, ["open"|my_path], [el_next|el_path], pressure_released + minutes_remaining_at_end_of_move * my_loc_flow_rate}
      end)

      el_map = Map.put(map, el_location, {0, el_next_locations})
      el_options = Enum.map(my_next_locations, fn my_next ->
        {el_map, my_next, el_location, [my_next|my_path], ["open"|el_path], pressure_released + minutes_remaining_at_end_of_move * el_loc_flow_rate}
      end)

      neither_map = map  # Neither one of us is opening a valve
      neither_options = Enum.flat_map(my_next_locations, fn my_next ->
        Enum.map(el_next_locations, fn el_next ->
          {neither_map, my_next, el_next, [my_next|my_path], [el_next|el_path], pressure_released}
        end)
      end)

      both_options ++ me_options ++ el_options ++ neither_options
    end)
    |> Enum.sort_by(&(&1 |> elem(5)), &>=/2)
    |> Enum.take(100000)  # Had to take 3 guesses on AoC website before arriving at a large enough cut-off :)
  end

  def bfs2(map, num_steps \\ 26) do
    Enum.reduce(num_steps-1..0, [{map, "AA", "AA", [], [], 0}], fn min_remain, acc ->
      bfs2_step(acc, min_remain)
    end)
    |> Enum.take(1)
  end

  def p2() do
    map = input() |> parse()
    bfs2(map)
  end
end
