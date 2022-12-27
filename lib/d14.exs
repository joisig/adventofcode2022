defmodule D14 do
  def demo_input() do
    """
    498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9
    """ |> String.trim()
  end

  def input(), do: File.read!("data/d14")

  def parse(input) do
    input |> String.split("\n")
    |> Enum.map(fn line ->
      line |> String.split(" -> ")
      |> Enum.map(fn pair ->
        [x,y] = pair |> String.split(",")
        |> Enum.map(fn val ->
          Integer.parse(val) |> elem(0)
        end)
        {x,y}
      end)
    end)
    |> rules_to_grid()
    |> add_max_y()
  end

  def add_max_y(map) do
    max = Enum.reduce(map, nil, fn {{_, y}, _}, acc ->
      case acc do
        nil -> y
        prev when prev < y -> y
        prev -> prev
      end
    end)
    {max, map}
  end

  def advance_first([{fx, fy}, {tx, ty}|_] = [_|rest]) do
    {fx, fy} = if fx == tx do
      {fx, fy + div(ty - fy, abs(ty - fy))}
    else
      {fx + div(tx - fx, abs(tx - fx)), fy}
    end
    [{fx, fy}|rest]
  end

  def to_grid(map, [_]), do: map
  def to_grid(map, [from, to|_] = [_|rest] = rules) when from == to do
    map = Map.put(map, from, :r)
    to_grid(map, rest)
  end
  def to_grid(map, [from, to|_] = rule) when is_list(rule) do
    map = Map.put(map, from, :r)
    to_grid(map, advance_first(rule))
  end

  def rules_to_grid(rules) do
    Enum.reduce(rules, %{}, fn rule, acc ->
      to_grid(acc, rule)
    end)
  end

  def move_sand(map, max_y, {_,y}) when y == max_y, do: {:abyss, map}
  def move_sand(map, max_y, {x,y} = current) do
    case {Map.get(map, {x-1,y+1}, nil), Map.get(map, {x,y+1}, nil), Map.get(map, {x+1,y+1}, nil)} do
      {_, nil, _} ->
        move_sand(map, max_y, {x, y+1})
      {nil, _, _} ->
        move_sand(map, max_y, {x-1, y+1})
      {_, _, nil} ->
        move_sand(map, max_y, {x+1, y+1})
      _ ->
        {:rest, Map.put(map, current, :s)}
    end
  end

  def p1() do
    {max_y, map} = input() |> parse
    p1_impl(map, max_y, 0)
  end

  def p1_impl(map, max_y, num_sand_placed) do
    case move_sand(map, max_y, {500,0}) do
      {:rest, map} -> p1_impl(map, max_y, num_sand_placed + 1)
      {:abyss, _} -> num_sand_placed
    end
  end

  def move_sand2(map, max_y, {_,y} = current) when y == max_y + 1 do
    {:rest, Map.put(map, current, :s)}
  end
  def move_sand2(map, max_y, {x,y} = current) do
    case Map.get(map, {500,0}, nil) do
      nil ->
        case {Map.get(map, {x-1,y+1}, nil), Map.get(map, {x,y+1}, nil), Map.get(map, {x+1,y+1}, nil)} do
          {_, nil, _} ->
            move_sand2(map, max_y, {x, y+1})
          {nil, _, _} ->
            move_sand2(map, max_y, {x-1, y+1})
          {_, _, nil} ->
            move_sand2(map, max_y, {x+1, y+1})
          _ ->
            {:rest, Map.put(map, current, :s)}
        end
      :s ->
        {:done, map}
    end
  end

  def p2() do
    {max_y, map} = input() |> parse
    p2_impl(map, max_y, 0)
  end

  def p2_impl(map, max_y, num_sand_placed) do
    {:rest, map} = move_sand2(map, max_y, {500,0})
    case map[{500,0}] do
      nil -> p2_impl(map, max_y, num_sand_placed + 1)
      _ -> num_sand_placed + 1
    end
  end

end
