defmodule D15 do
  def demo_input() do
    ~S"""
    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3
    """ |> String.trim
  end

  def input(), do: File.read!("data/d15")

  def all_ints(line) do
    Enum.map(Regex.scan(~r/-?[0-9]+/, line), fn [match] ->
      Integer.parse(match) |> elem(0)
    end)
  end

  def parse(input) do
    input |> String.split("\n") |> Enum.map(fn line ->
      [sx, sy, bx, by] = all_ints(line)
      {{sx, sy}, {bx, by}}
    end)
  end

  def manhattan_distance({sx, sy}, {ex, ey}) do
    abs(ex-sx) + abs(ey-sy)
  end

  def circumference(start, 0, acc), do: [start|acc]
  def circumference({sx,sy}, manhattan, acc) do
    {_, acc} = Enum.reduce(1..manhattan, {{sx-manhattan,sy}, acc}, fn _step, {{x,y}, acc} ->
      {next_x, next_y} = {x+1, y+1}
      {{next_x, next_y}, [{x,y}|acc]}
    end)
    {_, acc} = Enum.reduce(1..manhattan, {{sx,sy+manhattan}, acc}, fn _step, {{x,y}, acc} ->
      {next_x, next_y} = {x+1, y-1}
      {{next_x, next_y}, [{x,y}|acc]}
    end)
    {_, acc} = Enum.reduce(1..manhattan, {{sx+manhattan,sy}, acc}, fn _step, {{x,y}, acc} ->
      {next_x, next_y} = {x-1, y-1}
      {{next_x, next_y}, [{x,y}|acc]}
    end)
    {_, acc} = Enum.reduce(1..manhattan, {{sx,sy-manhattan}, acc}, fn _step, {{x,y}, acc} ->
      {next_x, next_y} = {x-1, y+1}
      {{next_x, next_y}, [{x,y}|acc]}
    end)
    acc
  end

  def all_coords_within(start, max_manhattan) do
    Enum.reduce(0..max_manhattan, [], fn manhattan, acc ->
      circumference(start, manhattan, acc)
    end)
  end

  def make_map(inputs) do
    Enum.reduce(inputs, %{}, fn {{sx,sy}=sensor, {bx,by}=beacon}, acc ->
      acc = Map.put(acc, {bx,by}, :beacon)
      Enum.reduce(all_coords_within({sx,sy}, manhattan_distance(sensor, beacon)), acc, fn {x,y}, acc ->
        Map.put_new(acc, {x,y}, :no_beacon)
      end)
    end)
  end

  def p1_too_slow() do
    map = input() |> parse() |> make_map()
    map |> Enum.filter(fn {{_,y}, val} -> val != nil and y == 2000000 end)
  end

  # Turns out the above is a very bad approach for large numbers :)

  def p1(y \\ 2000000) do
    pairs = input() |> parse()
    beacons = Enum.map(pairs, fn {_, beacon} -> beacon end) |> Enum.into(MapSet.new)
    sensors_and_distances = Enum.map(pairs, fn {sensor, beacon} -> {sensor, manhattan_distance(sensor, beacon)} end)
    IO.inspect sensors_and_distances, limit: :infinity
    {_, max_distance} = Enum.max_by(sensors_and_distances, fn {sensor, distance} -> distance end)
    {{min_x, _}, _} = Enum.min_by(pairs, fn {{x, _}, _} -> x end)
    {{max_x, _}, _} = Enum.max_by(pairs, fn {{x, _}, _} -> x end)
    {min_x, max_x, max_distance}
    min_x = min_x - max_distance - 10  # off by 10?
    max_x = max_x + max_distance + 10
    Enum.reduce(min_x..max_x, 0, fn x, acc ->
      case {x,y} in beacons do
        true ->
          acc
        false ->
          within_sensor_range = Enum.any?(sensors_and_distances, fn {sensor, distance} ->
            manhattan_distance(sensor, {x,y}) <= distance
          end)
          if within_sensor_range do
            acc + 1
          else
            acc
          end
      end
    end)
  end

  # Some false negatives but will be used in a 2-dimensional binary search, so it's OK
  def entire_square_within_range({x,y} = top_left, dimension, sensors_and_distances) do
    half_dim = case dimension do
      1 -> 0
      _ -> ceil(dimension / 2)
    end
    mid = {x + half_dim, y + half_dim}
    max_additional_distance = half_dim * 2
    Enum.any?(sensors_and_distances, fn {sensor, manhattan} ->
      manhattan >= (manhattan_distance(sensor, mid) + max_additional_distance)
    end)
  end

  def p2() do
    pairs = input() |> parse()
    sensors_and_distances = Enum.map(pairs, fn {sensor, beacon} -> {sensor, manhattan_distance(sensor, beacon)} end)
    {x, y} = p2_impl({0, 0}, 4000000, sensors_and_distances)
    x * 4000000 + y
  end

  def p2_impl({x,y} = top_left, dimension, sensors_and_distances) do
    half = ceil(dimension / 2)
    tls = {x,y}
    trs = {x + half, y}
    bls = {x, y + half}
    brs = {x + half, y + half}
    Enum.reduce([tls, trs, bls, brs], :not_here, fn square, acc ->
      case acc do
        :not_here ->
          result = entire_square_within_range(square, half, sensors_and_distances)
          case {result, dimension} do
            {false, 1} ->
              square
            {true, _} ->
              :not_here
            {false, _} ->
              p2_impl(square, half, sensors_and_distances)
          end
        _ ->
          acc
      end
    end)
  end

end
