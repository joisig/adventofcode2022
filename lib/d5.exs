defmodule D5 do
  def demo_input do
    ~S"""
        [D]
    [N] [C]
    [Z] [M] [P]
     1   2   3

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
  end

  def demo_input_2 do
    ~S"""
        [B]             [B] [S]
        [M]             [P] [L] [B] [J]
        [D]     [R]     [V] [D] [Q] [D]
        [T] [R] [Z]     [H] [H] [G] [C]
        [P] [W] [J] [B] [J] [F] [J] [S]
    [N] [S] [Z] [V] [M] [N] [Z] [F] [M]
    [W] [Z] [H] [D] [H] [G] [Q] [S] [W]
    [B] [L] [Q] [W] [S] [L] [J] [W] [Z]
    1   2   3   4   5   6   7   8   9

    move 3 from 5 to 2
    move 5 from 3 to 1
    move 4 from 4 to 9
    move 6 from 1 to 4
    """
  end

  def input do
    File.read!("data/d5")
  end

  def p1_to_blocks(text) do
    [picture_lines, instruction_lines] = String.split(text, "\n\n")
    [_|picture_lines] = picture_lines |> String.split("\n") |> Enum.reverse

    instruction_lines = instruction_lines
    |> String.trim
    |> String.split("\n")

    {picture_lines, instruction_lines}
  end

  def eat_delimiter(line, tower, acc) do
    case line do
      " " <> rest ->
        eat_line(rest, tower, acc)
      "" ->
        acc
    end
  end

  def eat_line(line, tower, acc) do
    case line do
      "   " <> rest ->
        eat_delimiter(rest, tower + 1, acc)
      <<"[", c::integer-8, "]", rest::binary>> ->
        acc = Map.put(acc, tower, [[c]|Map.get(acc, tower)])
        eat_delimiter(rest, tower + 1, acc)
    end
  end

  def picture_from_reversed_lines(lines) do
    towers = Enum.zip(1..9, List.duplicate([], 9)) |> Enum.into(%{})
    Enum.reduce(lines, towers, fn line, acc ->
      acc = eat_line(line, 1, acc)
    end)
  end

  def instruction_from_lines(lines) do
    lines |> Enum.map(fn line ->
      [_|str_nums] = line |> String.split(~r/move | from | to /)
      [count, from, to] = str_nums |> Enum.map(&(Integer.parse(&1) |> elem(0)))
      {count, from, to}
    end)
  end

  def parse_p1(lines) do
    {picture_lines, instruction_lines} = p1_to_blocks(lines)
    {picture_from_reversed_lines(picture_lines), instruction_from_lines(instruction_lines)}
  end

  def do_single_move(picture, from, to) do
    IO.inspect {picture, from, to}
    case Map.get(picture, from) do
      [] -> picture
      [moving|new_from] ->
        picture = Map.put(picture, from, new_from)
        new_to = [moving|Map.get(picture, to)]
        picture = Map.put(picture, to, new_to)
    end
  end

  def do_multiple_moves(picture, count, from, to) do
    Enum.reduce(1..count, picture, fn _, acc ->
      do_single_move(acc, from, to)
    end)
  end

  def calc_p1({picture, instructions}) do
    Enum.reduce(instructions, picture, fn {times, from, to}, acc ->
      do_multiple_moves(acc, times, from, to)
    end)
  end

  def p1() do
    input() |> parse_p1() |> calc_p1
    |> Map.to_list()
    |> Enum.sort_by(&(&1 |> elem(0)))
    |> Enum.flat_map(fn {_tower, [first|_]} ->
      first
    end)
  end

  def do_simultaneous_moves(picture, count, from, to) do
    # Hack around a bit to reuse the existing functions.
    picture = Map.put(picture, -1, [])
    picture = do_multiple_moves(picture, count, from, -1)
    picture = do_multiple_moves(picture, count, -1, to)
    picture = Map.delete(picture, -1)
  end

  def calc_p2({picture, instructions}) do
    Enum.reduce(instructions, picture, fn {times, from, to}, acc ->
      do_simultaneous_moves(acc, times, from, to)
    end)
  end

  def p2() do
    input() |> parse_p1() |> calc_p2
    |> Map.to_list()
    |> Enum.sort_by(&(&1 |> elem(0)))
    |> Enum.flat_map(fn {_tower, [first|_]} ->
      first
    end)
  end
end
