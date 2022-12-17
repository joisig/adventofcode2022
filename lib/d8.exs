defmodule D8 do
  def demo_input() do
    ~S"""
    30373
    25512
    65332
    33549
    35390
    """
  end

  def input(), do: File.read!("data/d8")

  def parse(text) do
    rows = text |> String.trim |> String.split("\n")
    |> Enum.map(fn str -> str |> to_charlist |> Enum.map(fn char -> char - ?0 end) end)
    dimension = Enum.count(rows)

    {_, _, map} = rows
    |> Enum.reduce({0, 0, %{}}, fn row, acc ->
      {x, y, map} = Enum.reduce(row, acc, fn height, {x, y, map} ->
        map = Map.put(map, {x,y}, height)
        {x + 1, y, map}
      end)
      {0, y + 1, map}
    end)

    Map.put(map, :max, dimension - 1)
  end

  def make_coord(:row_rev, fixed_index, i), do: {i, fixed_index}
  def make_coord(:col_rev, fixed_index, i), do: {fixed_index, i}

  def items_from_edge(map, :row, row_index), do: items_from_edge(map, :row_rev, row_index) |> Enum.reverse
  def items_from_edge(map, :col, col_index), do: items_from_edge(map, :col_rev, col_index) |> Enum.reverse
  def items_from_edge(map, dir, fixed_index) do
    Enum.reduce(0..map.max, [], fn i, acc ->
      coord = make_coord(dir, fixed_index, i)
      [{coord, Map.get(map, coord)}|acc]
    end)
  end

  def filter_visible(list) do
    Enum.reduce(list, {-1, []}, fn {coord, height}, {min_height, visible} ->
      if height > min_height do
        {height, [coord|visible]}
      else
        {min_height, visible}
      end
    end)
    |> elem(1)
    |> Enum.reverse
  end

  def visible_into_set(map, set, dir, i) do
    items_from_edge(map, dir, i) |> filter_visible |> Enum.into(set)
  end

  def calc_p1(map) do
    Enum.reduce(0..map.max, MapSet.new, fn i, set ->
      set = visible_into_set(map, set, :row, i)
      set = visible_into_set(map, set, :row_rev, i)
      set = visible_into_set(map, set, :col, i)
      set = visible_into_set(map, set, :col_rev, i)
      set
    end)
    |> Enum.count
  end

  def p1() do
    input() |> parse() |> calc_p1
  end

  def up({x,y}), do: {x,y-1}
  def down({x,y}), do: {x,y+1}
  def left({x,y}), do: {x-1,y}
  def right({x,y}), do: {x+1,y}

  def view_score(map, start_coord) do
    view_score_onedir(map, start_coord, &up/1)
    * view_score_onedir(map, start_coord, &down/1)
    * view_score_onedir(map, start_coord, &left/1)
    * view_score_onedir(map, start_coord, &right/1)
  end

  def view_score_onedir(map, start_coord, dir_fn) do
    initial_height = Map.get(map, start_coord)
    {score, _} = view_score_onedir_impl(map, start_coord, dir_fn, {0, initial_height})
    score
  end

  def view_score_onedir_impl(map, start_coord, dir_fn, {score_acc, block_height} = acc) do
    new_coord = dir_fn.(start_coord)
    case Map.get(map, new_coord) do
      nil ->
        acc  # Outside of map
      height ->
        if height >= block_height do
          {score_acc + 1, block_height}
        else
          view_score_onedir_impl(map, new_coord, dir_fn, {score_acc + 1, block_height})
        end
    end
  end

  def highest_view_score(map) do
    Enum.reduce(1..map.max, 0, fn x, max_score ->
      Enum.reduce(1..map.max, max_score, fn y, max_score ->
        case view_score(map, {x,y}) do
          score when score > max_score ->
            score
          _ ->
            max_score
        end
      end)
    end)
  end

  def p2() do
    D8.input |> D8.parse |> D8.highest_view_score
  end
end
