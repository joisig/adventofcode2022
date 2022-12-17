defmodule D10 do
  def demo_input() do
    ~S"""
    addx 15
    addx -11
    addx 6
    addx -3
    addx 5
    addx -1
    addx -8
    addx 13
    addx 4
    noop
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx -35
    addx 1
    addx 24
    addx -19
    addx 1
    addx 16
    addx -11
    noop
    noop
    addx 21
    addx -15
    noop
    noop
    addx -3
    addx 9
    addx 1
    addx -3
    addx 8
    addx 1
    addx 5
    noop
    noop
    noop
    noop
    noop
    addx -36
    noop
    addx 1
    addx 7
    noop
    noop
    noop
    addx 2
    addx 6
    noop
    noop
    noop
    noop
    noop
    addx 1
    noop
    noop
    addx 7
    addx 1
    noop
    addx -13
    addx 13
    addx 7
    noop
    addx 1
    addx -33
    noop
    noop
    noop
    addx 2
    noop
    noop
    noop
    addx 8
    noop
    addx -1
    addx 2
    addx 1
    noop
    addx 17
    addx -9
    addx 1
    addx 1
    addx -3
    addx 11
    noop
    noop
    addx 1
    noop
    addx 1
    noop
    noop
    addx -13
    addx -19
    addx 1
    addx 3
    addx 26
    addx -30
    addx 12
    addx -1
    addx 3
    addx 1
    noop
    noop
    noop
    addx -9
    addx 18
    addx 1
    addx 2
    noop
    noop
    addx 9
    noop
    noop
    noop
    addx -1
    addx 2
    addx -37
    addx 1
    addx 3
    noop
    addx 15
    addx -21
    addx 22
    addx -6
    addx 1
    noop
    addx 2
    addx 1
    noop
    addx -10
    noop
    noop
    addx 20
    addx 1
    addx 2
    addx 2
    addx -6
    addx -11
    noop
    noop
    noop
    """ |> String.trim()
  end

  def input(), do: File.read!("data/d10")

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      case line do
        "noop" <> _rest ->
          {:noop, 0}
        "addx " <> num ->
          {num, ""} = Integer.parse(num)
          {:addx, num}
      end
    end)
  end

  # acc is a map from cycle number to value at start of cycle
  def x_histogram(acc, [], cycle, val) do
    Map.put(acc, cycle, val)
  end
  def x_histogram(acc, [cmd|next_commands], cycle, val) do
    case cmd do
      {:noop, _} ->
        x_histogram(Map.put(acc, cycle, val), next_commands, cycle + 1, val)
      {:addx, inc} ->
        acc = acc |> Map.put(cycle, val) |> Map.put(cycle + 1, val)
        x_histogram(acc, next_commands, cycle + 2, val + inc)
    end
  end

  def p1() do
    commands = input() |> parse()
    res = x_histogram(%{}, commands, 1, 1)
    20 * res[20] + 60 * res[60] + 100 * res[100] + 140 * res[140] + 180 * res[180] + 220 * res[220]
  end

  def p2() do
    commands = input() |> parse()
    res = x_histogram(%{}, commands, 1, 1)
    Enum.map(0..240, fn ix ->
      cycle = ix + 1
      sprite_pos = res[cycle]
      sprites_at = [sprite_pos - 1, sprite_pos, sprite_pos + 1]
      if rem(ix, 40) in sprites_at do
        IO.write("#")
      else
        IO.write(".")
      end
      if rem((ix + 1), 40) == 0 do
        IO.write("\n")
      end
    end)
  end
end
