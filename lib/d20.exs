defmodule D20 do
  def demo_input() do
    ~S"""
    1
    2
    -3
    3
    -2
    0
    4
    """ |> String.trim
  end

  def input(), do: File.read!("data/d20")

  def parse(input) do
    numbers = input
    |> String.split("\n")
    |> Enum.map(&(Integer.parse(&1) |> elem(0)))
    radix_list = Enum.zip(0..(Enum.count(numbers) - 1), numbers)
    {Enum.count(radix_list), radix_list}
  end

  # Pretty naive implementation that traverses the list lots of
  # times. Could be made a lot more efficient using a single
  # reduce I think, but it probably doesn't matter.
  def move({count, list} = radix_list, radix) do
    at = Enum.find_index(list, fn {r, _} -> r == radix end)
    {^radix, value} = item = Enum.find(list, fn {r, _} -> r == radix end)
    list_without = case at do
      0 ->
        Enum.slice(list, 1..-1)
      ix when ix == (count - 1) ->
        Enum.slice(list, 0..-2)
      _ ->
        head = Enum.slice(list, 0..(at - 1))
        tail = Enum.slice(list, (at+1)..-1)
        tail ++ head
    end
    # Make an always-positive, always-less-than-list-length move value
    # The modulo is actually one less than count because you first pull
    # the item "out" and it is "between" others.
    move_amount = rem(rem(value, count - 1) + count - 1, count - 1)
    #IO.inspect list_without
    #IO.inspect move_amount
    moved_list = case move_amount do
      ma when ma == 0 or ma == (count - 1) ->
        [item|list_without]
      _ ->
        head = Enum.slice(list_without, 0..(move_amount - 1))
        tail = Enum.slice(list_without, move_amount..-1)
        head ++ [item] ++ tail
    end
    {count, moved_list}
  end

  def mix({count, list} = radix_list) do
    Enum.reduce(0..count-1, radix_list, fn radix, radix_list ->
      move(radix_list, radix)
    end)
  end

  def value_at_offset_from_0({count, list} = _radix_list, offset) do
    offset = offset + Enum.find_index(list, fn {_, v} -> 0 == v end)
    offset = rem(offset, count)
    Enum.at(list, offset) |> elem(1)
  end

  def p1() do
    result = input() |> parse() |> mix()
    value_at_offset_from_0(result, 1000) + value_at_offset_from_0(result, 2000) + value_at_offset_from_0(result, 3000)
  end

  def p2() do
    {count, raw_list} = input() |> parse()
    result = {count, Enum.map(raw_list, fn {radix, val} -> {radix, val * 811589153} end)}
    |> mix()
    |> mix()
    |> mix()
    |> mix()
    |> mix()
    |> mix()
    |> mix()
    |> mix()
    |> mix()
    |> mix()
    value_at_offset_from_0(result, 1000) + value_at_offset_from_0(result, 2000) + value_at_offset_from_0(result, 3000)
  end
end
