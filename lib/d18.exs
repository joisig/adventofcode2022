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

  def uncovered(map, coords) do
    1 - Map.get(map, coords, 0)
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
    [max_x, max_y, max_z] = Enum.reduce(v, [0,0,0], fn {[x,y,z], _}, acc ->
      [max(x,Enum.at(acc, 0)), max(y, Enum.at(acc,1)), max(z, Enum.att(acc,2))]
    end)
    [min_x, min_y, min_z] = Enum.reduce(v, [0,0,0], fn {[x,y,z], _}, acc ->
      [min(x,Enum.at(acc, 0)), min(y, Enum.at(acc,1)), min(z, Enum.att(acc,2))]
    end)
    {{min_x - 1, min_y - 1, min_z - 1}, {max_x + 1, max_y + 1, max_z + 1}}
  end
end
