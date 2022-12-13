defmodule D4 do
  def demo_input() do
    ~S"""
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
  end

  def inputs() do
    File.read!("data/d4")
  end

  def parse_p1(lines) do
    lines
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      line
      |> String.trim
      |> String.split(",")
      |> Enum.map(fn part ->
        part |> String.split("-") |> Enum.map(&(Integer.parse(&1) |> elem(0)))
      end)
    end)
    |> Enum.map(fn [[ll,lr], [rl,rr]] ->
      {{ll, lr}, {rl, rr}}
    end)
  end

  def right_covers_left({ll, lr}, {rl, rr}) do
    ll >= rl and lr <= rr
  end

  def calc_p1(inputs) do
    inputs
    |> Enum.filter(fn {left, right} ->
      right_covers_left(left, right) or right_covers_left(right, left)
    end)
    |> Enum.count()
  end

  def p1() do
    inputs() |> parse_p1() |> calc_p1()
  end

  def left_starts_or_ends_in_right({ll, lr}, {rl, rr}) do
    ll >= rl and ll <= rr
    or
    lr >= rl and lr <= rr
  end

  def calc_p2(inputs) do
    inputs
    |> Enum.filter(fn {left, right} ->
      left_starts_or_ends_in_right(left, right) or left_starts_or_ends_in_right(right, left)
    end)
    |> Enum.count()
  end

  def p2() do
    inputs() |> parse_p1() |> calc_p2()
  end
end
