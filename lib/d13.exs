defmodule D13 do
  def demo_input() do
    ~S"""
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
    """ |> String.trim
  end

  def input(), do: File.read!("data/d13")

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn chunk ->
      [left, right] = String.split(chunk, "\n") |> Enum.map(fn line ->
        {result, _} = Code.eval_string(line)
        result
      end)
      {left, right}
    end)
  end

  def parse2(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      {result, _} = Code.eval_string(line)
      result
    end)
  end

  def right_order(left, right) when is_integer(left) and is_integer(right) do
    if left < right do
      :correct
    else
      if left == right do
        :unknown
      else
        :incorrect
      end
    end
  end

  def right_order(left, right) when is_integer(left) do
    right_order([left], right)
  end

  def right_order(left, right) when is_integer(right) do
    right_order(left, [right])
  end

  def right_order([], []), do: :unknown
  def right_order([], right) when is_list(right), do: :correct
  def right_order(left, []) when is_list(left), do: :incorrect

  def right_order([lfirst|lrest] = left, [rfirst|rrest] = right) when is_list(left) and is_list(left) do
    case right_order(lfirst, rfirst) do
      :correct -> :correct
      :incorrect -> :incorrect
      :unknown -> right_order(lrest, rrest)
    end
  end

  def p1() do
    input = input |> parse
    with_indexes = Enum.zip(1..Enum.count(input), input)
    Enum.map(with_indexes, fn {index, {left, right}} ->
      case right_order(left, right) do
        :correct -> index
        :incorrect -> 0
      end
    end)
    |> Enum.sum()
  end

  def p2() do
    input = (input |> parse2) ++ [[[2]], [[6]]]
    sorted = Enum.sort(input, fn l, r ->
      :correct == right_order(l, r)
    end)
    with_indexes = Enum.zip(1..Enum.count(input), sorted)
    Enum.reduce(with_indexes, 1, fn {index, val}, acc ->
      case val do
        [[2]] -> acc * index
        [[6]] -> acc * index
        _ -> acc
      end
    end)
  end
end
