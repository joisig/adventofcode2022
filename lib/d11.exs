defmodule D11 do
  def demo_input() do
    ~S"""
    Monkey 0:
      Starting items: 79, 98
      Operation: new = old * 19
      Test: divisible by 23
        If true: throw to monkey 2
        If false: throw to monkey 3

    Monkey 1:
      Starting items: 54, 65, 75, 74
      Operation: new = old + 6
      Test: divisible by 19
        If true: throw to monkey 2
        If false: throw to monkey 0

    Monkey 2:
      Starting items: 79, 60, 97
      Operation: new = old * old
      Test: divisible by 13
        If true: throw to monkey 1
        If false: throw to monkey 3

    Monkey 3:
      Starting items: 74
      Operation: new = old + 3
      Test: divisible by 17
        If true: throw to monkey 0
        If false: throw to monkey 1
    """ |> String.trim
  end

  def input(), do: File.read!("data/d11")

  def parse(input) do
    monkeys = input
    |> String.split("\n\n")
    |> Enum.map(fn monkey_lines ->
      String.split(monkey_lines, "\n") |> parse_monkey()
    end)
    max = Enum.max_by(monkeys, &(&1 |> elem(0))) |> elem(0)
    monkeys |> Enum.into(%{}) |> Map.put(:max, max)
  end

  def parse_monkey(["Monkey " <> monkey_num,
                    "  Starting items: " <> items,
                    "  Operation: " <> operation,
                    "  Test: divisible by " <> divisible,
                    "    If true: throw to monkey " <> true_to,
                    "    If false: throw to monkey " <> false_to], divide \\ true) do
    {monkey_num, ":"} = Integer.parse(monkey_num)
    {divisible, ""} = Integer.parse(divisible)
    items = String.split(items, ", ") |> Enum.map(&(&1 |> Integer.parse |> elem(0)))
    {true_to, ""} = Integer.parse(true_to)
    {false_to, ""} = Integer.parse(false_to)
    {monkey_num, {items, parse_operation(operation), divisible, true_to, false_to, 0}}
  end

  # KISS for now, no need to get into proper parsing
  def parse_operation("new = old " <> rest) do
    case rest do
      "* old" ->
        fn old -> old * old end
      "* " <> rest ->
        {rest, ""} = Integer.parse(rest)
        fn old -> old * rest end
      "+ " <> rest ->
        {rest, ""} = Integer.parse(rest)
        fn old -> old + rest end
    end
  end

  def monkey_do(map, ix, divide) do
    {items, operation, divisible, true_to, false_to, inspection_count} = Map.get(map, ix)
    map = Enum.reduce(items, map, fn item, acc ->
      item = operation.(item)
      item = case divide do
        true -> trunc(item / 3)
        false -> item
      end
      case rem(item, divisible) do
        0 -> throw_to_monkey(acc, item, true_to)
        _ -> throw_to_monkey(acc, item, false_to)
      end
    end)
    Map.put(map, ix, {[], operation, divisible, true_to, false_to, inspection_count + Enum.count(items)})
  end

  def throw_to_monkey(map, item, ix) do
    divisor = Enum.reduce(map, 1, fn
      {_, {_, _, div, _, _, _}}, acc -> acc * div
      _, acc -> acc
    end)
    {items, op, div, t, f, ic} = Map.get(map, ix)
    Map.put(map, ix, {items ++ [rem(item, divisor)], op, div, t, f, ic})
  end

  def calc(map, divide, rounds) do
    Enum.reduce(1..rounds, map, fn _round_ix, map ->
      Enum.reduce(0..map.max, map, fn ix, map ->
        monkey_do(map, ix, divide)
      end)
    end)
  end

  def to_monkey_business_number(results) do
    handled_counts = results
    |> Enum.flat_map(fn {_k, v} ->
      case v do
        {_, _, _, _, _, count} -> [count]
        _ -> []
      end
    end)

    [top, next|_rest] = Enum.sort(handled_counts, &>=/2)
    top * next
  end

  def p1() do
    input() |> parse() |> calc(true, 20) |> to_monkey_business_number
  end

  def p2() do
    input() |> parse() |> calc(false, 10000) |> to_monkey_business_number()
  end
end
