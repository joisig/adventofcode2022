defmodule D9 do
  def demo_input do
    ~S"""
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
    |> String.trim
  end

  def input(), do: File.read!("data/d9")

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      {move, rest} = case line do
        "R " <> rest -> {:right, rest}
        "L " <> rest -> {:left, rest}
        "U " <> rest -> {:up, rest}
        "D " <> rest -> {:down, rest}
      end
      {count, ""} = Integer.parse(rest)
      {move, count}
    end)
  end

  def move_tail_if_needed({hx, hy}, {tx, ty}) do
    if abs(hx - tx) <= 1 and abs(hy - ty) <= 1 do
      {tx, ty}
    else
      if hx == tx do
        if hy < ty do
          {tx, ty - 1}
        else
          {tx, ty + 1}
        end
      else
        if hy == ty do
          if hx < tx do
            {tx - 1, ty}
          else
            {tx + 1, ty}
          end
        else
          if hx < tx and hy < ty do
            {tx - 1, ty - 1}
          else
            if hx < tx and hy > ty do
              {tx - 1, ty + 1}
            else
              if hx > tx and hy < ty do
                {tx + 1, ty - 1}
              else
                {tx + 1, ty + 1}
              end
            end
          end
        end
      end
    end
  end

  def move(:up, {x,y}), do: {x, y-1}
  def move(:down, {x,y}), do: {x, y+1}
  def move(:left, {x,y}), do: {x-1, y}
  def move(:right, {x,y}), do: {x+1, y}

  def perform_head_move({{hx,hy} = head, {tx,ty} = tail, visit_set}, {dir, count}) do
    case count do
      0 ->
        {head, tail, visit_set}
      _ ->
        head = move(dir, head)
        tail = move_tail_if_needed(head, tail)
        perform_head_move({head, tail, MapSet.put(visit_set, tail)}, {dir, count - 1})
    end
  end

  def simulate_rope(moves) do
    Enum.reduce(moves, {{0,0}, {0,0}, MapSet.new}, fn move, acc ->
      perform_head_move(acc, move)
    end)
  end

  def p1() do
    D9.input |> D9.parse |> D9.simulate_rope |> elem(2) |> Enum.count
  end
end
