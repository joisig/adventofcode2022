defmodule D18 do
  def demo_input() do
    ~S"""
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
    """ |> String.trim()
  end

  def input(), do: File.read!("data/d18")

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(fn item ->
        {num, ""} = Integer.parse(item)
        num
      end)
    end)
    |> Enum.reduce(%{}, fn key, acc ->
      Map.put(acc, key, 1)
    end)
  end

  def up([x,y,z]), do: [x,y,z+1]
  def down([x,y,z]), do: [x,y,z-1]
  def left([x,y,z]), do: [x-1,y,z]
  def right([x,y,z]), do: [x+1,y,z]
  def toward([x,y,z]), do: [x,y-1,z]
  def away([x,y,z]), do: [x,y+1,z]

  def uncovered(map, [x,y,z] = coords) do
    {{min_x, min_y, min_z}, {max_x, max_y, max_z}} = Process.get(:min_max_coords)
    case [x,y,z] do
      [d,_,_] when d < min_x or d > max_x -> 0
      [_,d,_] when d < min_y or d > max_y -> 0
      [_,_,d] when d < min_z or d > max_z -> 0
      _ ->
        case Map.get(map, coords) do
          1 -> 0
          2 -> 0
          nil -> 1
        end
    end
  end

  def uncovered_for_voxel(map, coords) do
    uncovered(map, up(coords)) +
    uncovered(map, down(coords)) +
    uncovered(map, left(coords)) +
    uncovered(map, right(coords)) +
    uncovered(map, toward(coords)) +
    uncovered(map, away(coords))
  end

  def uncovered_for_droplet(map) do
    Enum.map(map, fn {coords, _} ->
      uncovered_for_voxel(map, coords)
    end)
    |> Enum.sum()
  end

  def p1() do
    input() |> parse() |> uncovered_for_droplet()
  end

  def min_max_coords(map) do
    [max_x, max_y, max_z] = Enum.reduce(map, [1,1,1], fn {[x,y,z], _}, acc ->
      [max(x,Enum.at(acc, 0)), max(y, Enum.at(acc,1)), max(z, Enum.at(acc,2))]
    end)
    [min_x, min_y, min_z] = Enum.reduce(map, [1,1,1], fn {[x,y,z], _}, acc ->
      [min(x,Enum.at(acc, 0)), min(y, Enum.at(acc,1)), min(z, Enum.at(acc,2))]
    end)
    {{min_x - 1, min_y - 1, min_z - 1}, {max_x + 1, max_y + 1, max_z + 1}}
  end

  def fill_empty(map, coords) do
    case uncovered(map, coords) do
      0 ->
        map
      _ ->
        map = Map.put(map, coords, 2)
        map = fill_empty(map, up(coords))
        map = fill_empty(map, down(coords))
        map = fill_empty(map, left(coords))
        map = fill_empty(map, right(coords))
        map = fill_empty(map, toward(coords))
        map = fill_empty(map, away(coords))
        map
    end
  end

  def p2() do
    map = input() |> parse()
    min_max_coords = {{min_x, min_y, min_z}, {max_x, max_y, max_z}} = min_max_coords(map)
    Process.put(:min_max_coords, min_max_coords)
    map = fill_empty(map, [min_x, min_y, min_z])
    # Any voxel inside the bounding box that is not a 2 ("gas")
    # is now the surface that we consider.
    map = Enum.filter(map, fn {_, val} -> val == 2 end) |> Enum.into(%{})
    no_gas = Enum.reduce(min_x..max_x, %{}, fn x, acc ->
      Enum.reduce(min_y..max_y, acc, fn y, acc ->
        Enum.reduce(min_z..max_z, acc, fn z, acc ->
          case Map.get(map, [x,y,z]) do
            2 -> Map.put(acc, [x,y,z], 1)
            _ -> acc
          end
        end)
      end)
    end)
    uncovered_for_droplet(no_gas)
  end
end
