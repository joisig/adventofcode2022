defmodule D2 do
  def demo_input() do
    ~S"""
    A Y
    B X
    C Z
    """
  end

  def input() do
    File.read!("data/d2")
  end

  def parse_input_p1(input_lines) do
    lines = String.split(input_lines, "\n") |> Enum.filter(&(&1 != ""))
    Enum.map(lines, fn <<they::integer-8, " ", us::integer-8>> ->
      they = case they do
        ?A -> :rock
        ?B -> :paper
        ?C -> :scissors
      end
      us = case us do
        ?X -> :rock
        ?Y -> :paper
        ?Z -> :scissors
      end
      {they, us}
    end)
  end

  def calc_p1(input) do
    Enum.map(input, fn {they, us} ->
      case us do
        :rock ->
          case they do
            :rock -> 3 + 1
            :scissors -> 6 + 1
            :paper -> 0 + 1
          end
        :paper ->
          case they do
            :paper -> 3 + 2
            :rock -> 6 + 2
            :scissors -> 0 + 2
          end
        :scissors ->
          case they do
            :scissors -> 3 + 3
            :paper -> 6 + 3
            :rock -> 0 + 3
          end
      end
    end)
    |> Enum.sum
  end

  def p1() do
    input() |> parse_input_p1() |> calc_p1()
  end

  def parse_input_p2(input_lines) do
    lines = String.split(input_lines, "\n") |> Enum.filter(&(&1 != ""))
    Enum.map(lines, fn <<they::integer-8, " ", us::integer-8>> ->
      they = case they do
        ?A -> :rock
        ?B -> :paper
        ?C -> :scissors
      end
      us = case us do
        ?X -> :lose
        ?Y -> :draw
        ?Z -> :win
      end
      {they, us}
    end)
  end

  def calc_p2(input) do
    Enum.map(input, fn {they, action} ->
      for_action = case action do
        :win -> 6
        :draw -> 3
        :lose -> 0
      end
      for_move = case they do
        :rock ->
          case action do
            :win -> 2  # paper
            :draw -> 1  # rock
            :lose -> 3  # scissors
          end
        :paper ->
          case action do
            :win -> 3  # scissors
            :draw -> 2  # paper
            :lose -> 1  # scissors
          end
        :scissors ->
          case action do
            :win -> 1  # rock
            :draw -> 3  # scissors
            :lose -> 2  # paper
          end
      end
      for_move + for_action
    end)
    |> Enum.sum
  end

  def p2() do
    input() |> parse_input_p2() |> calc_p2()
  end

end
