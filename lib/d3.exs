defmodule D3 do
  alias Inspect.HashSet
  def demo_input() do
    ~S"""
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
  end

  def input_p1() do
    File.read!("data/d3")
  end

  def parse_p1(input_lines) do
    lines = String.split(input_lines) |> Enum.filter(&(&1 != ""))
    Enum.map(lines, fn line ->
      clen = String.length(line) / 2 |> trunc
      chars = String.to_charlist(line)
      c1 = Enum.take(chars, clen) |> Enum.into(MapSet.new())
      c2 = Enum.take(chars, -clen) |> Enum.into(MapSet.new())
      {c1, c2}
    end)
  end

  def char_to_priority(c) do
    IO.inspect {[c] |> to_string, c, ?A, ?a}
    case c >= ?a do
      true -> c - ?a + 1
      false -> c - ?A + 1 + 26
    end
  end

  def calc_p1(inputs) do
    Enum.map(inputs, fn {c1, c2} ->
      MapSet.intersection(c1, c2) |> Enum.reduce(0, fn item, acc -> char_to_priority(item) + acc end)
    end)
    |> Enum.sum
  end

  def p1() do
    input_p1 |> parse_p1 |> calc_p1
  end

  def parse_p2(input_lines) do
    String.split(input_lines)
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&(String.to_charlist(&1) |> Enum.into(MapSet.new())))
  end

  def calc_p2(inputs) do
    Enum.chunk_every(inputs, 3)
    |> Enum.map(fn [e1, e2, e3] ->
      set = MapSet.intersection(e1, e2) |> MapSet.intersection(e3) |> Enum.into([])
    end)
    |> Enum.map(fn [char] -> char_to_priority(char) end)
    |> Enum.sum
  end
end
