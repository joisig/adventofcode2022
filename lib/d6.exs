defmodule D6 do
  def demo_input() do
    "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
  end

  def input() do
    File.read!("data/d6")
  end

  def calc_p1([first_char|rest_chars], pos \\ 0, tail \\ []) do
    case tail do
      [t1, t2, t3, t4] ->
        if Enum.uniq(tail) == tail do
          pos
        else
          calc_p1(rest_chars, pos + 1, [first_char, t1, t2, t3])
        end
      _ ->
        calc_p1(rest_chars, pos + 1, [first_char|tail])
    end
  end

  def calc_p2([first_char|rest_chars], pos \\ 0, tail \\ []) do
    case Enum.count(tail) do
      14 ->
        if Enum.uniq(tail) == tail do
          pos
        else
          [_|rest_rev] = Enum.reverse(tail)
          rest = Enum.reverse(rest_rev)
          calc_p2(rest_chars, pos + 1, [first_char|rest])
        end
      _ ->
        calc_p2(rest_chars, pos + 1, [first_char|tail])
      end
  end

  def p1() do
    input() |> to_charlist() |> calc_p1()
  end

  def p2() do
    input() |> to_charlist() |> calc_p2()
  end
end
