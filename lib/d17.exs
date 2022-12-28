defmodule D17 do
  def demo_input(), do: ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

  def input(), do: File.read!("data/d17")

  def parse(input), do: to_charlist(input)

  def next_push([], [next_push|rest]) do
    {next_push, rest}
  end
  def next_push([next_push|rest], original_pushes) do
    {next_push, rest}
  end

  def test_next_push() do
    original_pushes = input |> parse
    Enum.reduce(1..10200, original_pushes, fn _, acc ->
      {next_push, rest} = next_push(acc, original_pushes)
      IO.binwrite([next_push])
      rest
    end)
    :ok
  end

  def shape_fits(shape_index, offset, map)
  # ****
  def shape_fits(0, {x,y} = offset, map) do
    y >= 0 and x >= 0 and x < (7-3) and map[offset] != 1 and map[{x+1,y}] != 1 and map[{x+2,y}] != 1 and map[{x+3,y}] != 1
  end
  # .*.
  # ***
  # .*.
  def shape_fits(1, {x,y}, map) do
    y >= 2 and x >= 0 and x < (7-2) and map[{x+1,y}] != 1 and map[{x,y-1}] != 1 and map[{x+1,y-1}] != 1 and map[{x+2,y-1}] != 1 and map[{x+1,y-2}] != 1
  end
  # ..*
  # ..*
  # ***
  def shape_fits(2, {x,y}, map) do
    y >= 2 and x >= 0 and x < (7-2) and map[{x+2,y}] != 1 and map[{x+2,y-1}] != 1 and map[{x,y-2}] != 1 and map[{x+1,y-2}] != 1 and map[{x+2,y-2}] != 1
  end
  # *
  # *
  # *
  # *
  def shape_fits(3, {x,y}, map) do
    y >= 3 and x >= 0 and x < 7 and map[{x,y}] != 1 and map[{x,y-1}] != 1 and map[{x,y-2}] != 1 and map[{x,y-3}] != 1
  end
  # **
  # **
  def shape_fits(4, {x,y}, map) do
    y >= 1 and x>= 0 and x < (7-1) and map[{x,y}] != 1 and map[{x+1,y}] != 1 and map[{x,y-1}] != 1 and map[{x+1,y-1}] != 1
  end

  def place_shape(shape_index, offset, map)
  def place_shape(0, {x,y}, map) do
    map |> Map.put({x,y}, 1) |> Map.put({x+1,y}, 1) |> Map.put({x+2,y}, 1) |> Map.put({x+3,y}, 1)
  end
  def place_shape(1, {x,y}, map) do
    map |> Map.put({x+1,y}, 1) |> Map.put({x,y-1}, 1) |> Map.put({x+1,y-1}, 1) |> Map.put({x+2,y-1}, 1) |> Map.put({x+1,y-2}, 1)
  end
  def place_shape(2, {x,y}, map) do
    map |> Map.put({x+2,y}, 1) |> Map.put({x+2,y-1}, 1) |> Map.put({x,y-2}, 1) |> Map.put({x+1,y-2}, 1) |> Map.put({x+2,y-2}, 1)
  end
  def place_shape(3, {x,y}, map) do
    map |> Map.put({x,y}, 1) |> Map.put({x,y-1}, 1) |> Map.put({x,y-2}, 1) |> Map.put({x,y-3}, 1)
  end
  def place_shape(4, {x,y}, map) do
    map |> Map.put({x,y}, 1) |> Map.put({x+1,y}, 1) |> Map.put({x,y-1}, 1) |> Map.put({x+1,y-1}, 1)
  end

  def max_y(map) do
    case Enum.empty?(map) do
      true ->
        -1
      false ->
        {{_, max_y}, _} = Enum.max_by(map, fn {{_,y}, _} -> y end)
        max_y
    end
  end

  def shape_start_y(shape_index, map)
  def shape_start_y(0, map), do: max_y(map) + 4
  def shape_start_y(1, map), do: max_y(map) + 6
  def shape_start_y(2, map), do: max_y(map) + 6
  def shape_start_y(3, map), do: max_y(map) + 7
  def shape_start_y(4, map), do: max_y(map) + 5

  def shape_start(shape_index, map), do: {2, shape_start_y(shape_index, map)}

  def move_shape_to_rest({pushes, map}, original_pushes, shape_index, {x,y}) do
    {next_push, pushes} = next_push(pushes, original_pushes)
    next_offset = case next_push do
      ?< -> -1
      ?> -> 1
    end
    {x,y} = case shape_fits(shape_index, {x+next_offset,y}, map) do
      true -> {x+next_offset, y}
      false -> {x,y}
    end
    case shape_fits(shape_index, {x,y-1}, map) do
      true ->
        move_shape_to_rest({pushes, map}, original_pushes, shape_index, {x,y-1})
      false ->
        map = place_shape(shape_index, {x,y}, map)
        {pushes, map}
    end
  end

  def move_shapes(count, original_pushes) do
    Enum.reduce(0..count-1, {original_pushes, %{}}, fn ix, {pushes, map} ->
      shape_ix = rem(ix, 5)
      move_shape_to_rest({pushes, map}, original_pushes, shape_ix, shape_start(shape_ix, map))
    end)
  end

  def visualize(map) do
    Enum.map(max_y(map)..0, fn y ->
      IO.write("|")
      Enum.map(0..6, fn x ->
        case map[{x,y}] do
          1 -> IO.write("#")
          _ -> IO.write(".")
        end
      end)
      IO.write("|\n")
    end)
    :ok
  end

  def p1(iterations \\ 2022) do
    original_pushes = input() |> parse()
    {_, map} = move_shapes(iterations, original_pushes)
    visualize(map)
    max_y(map) + 1
  end
end
