defmodule D21 do
  def input(), do: File.read!("data/d21")

  def demo_input() do
    ~S"""
    root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32
    """ |> String.trim
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn <<name::binary-size(4), ": ", rest::binary>> ->
      val = case rest do
        <<larg::binary-size(4), " * ", rarg::binary-size(4)>> ->
          {:mult, larg, rarg}
        <<larg::binary-size(4), " / ", rarg::binary-size(4)>> ->
          {:div, larg, rarg}
        <<larg::binary-size(4), " + ", rarg::binary-size(4)>> ->
          {:plus, larg, rarg}
        <<larg::binary-size(4), " - ", rarg::binary-size(4)>> ->
          {:minus, larg, rarg}
        num ->
          {num, ""} = Integer.parse(num)
          {:literal, num}
      end
      {name, val}
    end)
  end

  def resolve_op(_, :unresolved, _), do: :unresolved
  def resolve_op(_, _, :unresolved), do: :unresolved
  def resolve_op(:eq, _, _), do: :unresolved
  def resolve_op(:plus, l, r), do: l+r
  def resolve_op(:minus, l, r), do: l-r
  def resolve_op(:mult, l, r), do: l*r
  def resolve_op(:div, _, 0), do: :unresolved
  def resolve_op(:div, l, r) do
    IO.inspect {:ops, l, r}
    res = l/r
    if res != trunc(res), do: IO.inspect "l: #{l}, r: #{r}"
    trunc(res)
  end

  def resolve(vars, name, val) do
    case val do
      :unknown_literal -> {:unresolved, vars}
      {:literal, v} -> {:resolved, Map.put(vars, name, v)}
      {op, larg, rarg} ->
        larg = Map.get(vars, larg, :unresolved)
        rarg = Map.get(vars, rarg, :unresolved)
        case resolve_op(op, larg, rarg) do
          :unresolved -> {:unresolved, vars}
          v -> {:resolved, Map.put(vars, name, v)}
        end
    end
  end

  def calc_step({monkeys, vars}) do
    Enum.reduce(monkeys, {[], vars}, fn {name, val} = monkey, {deferred_monkeys, vars} ->
      case resolve(vars, name, val) do
        {:resolved, v} -> {deferred_monkeys, v}
        {:unresolved, v} -> {[monkey|deferred_monkeys], v}
      end
    end)
  end

  def calc({monkeys, vars}, target_element) do
    {monkeys2, vars2} = calc_step({monkeys, vars})
    case Map.get(vars2, target_element) do
      nil ->
        calc({monkeys2, vars2}, target_element)
      val ->
        val
    end
  end

  def p1() do
    monkeys = input() |> parse()
    calc({monkeys, %{}}, "root")
  end

  def munge_for_p2(monkeys) do
    Enum.flat_map(monkeys, fn {name, val} ->
      val = case name do
        "root" ->
          {_op, l, r} = val
          [{name, {:eq, l, r}}]
        "humn" -> []
        _ -> [{name, val}]
      end
    end)
  end

  # This is an algebraic rewrite of the initial relationship
  # between numbers for what it is from the perspective of
  # the original l-parameter
  def inverse_monkeys(monkeys) do
    Enum.map(monkeys, fn {name, {op, l, r}} ->
      inverse_op = case op do
        :plus -> :minus
        :minus -> :plus
        :mult -> :div
        :div -> :mult
      end
      {l, {inverse_op, name, r}}
    end)
  end

  # Same as above except from the perspective of the r-parameter
  def converse_monkeys(monkeys) do
    Enum.map(monkeys, fn {name, {op, l, r}} ->
      case op do
        :plus -> {r, {:minus, name, l}}
        :minus -> {r, {:plus, name, l}}
        :mult -> {r, {:div, name, l}}
        :div -> {r, {:div, r, name}}  # Supplies!
      end
    end)
  end

  def try_calc(_, _, _, _, current_guess, max_guess) when current_guess == max_guess, do: "not found"
  def try_calc(target_name, target_value, monkeys, vars, current_guess, max_guess) do
    #IO.inspect "Trying #{current_guess}, target name #{target_name}"
    #IO.inspect {monkeys, vars}
    value = calc({monkeys, Map.put(vars, "humn", current_guess)}, target_name)
    #IO.inspect {:val, target_name, value}
    case value do
      ^target_value -> current_guess
      _ -> try_calc(target_name, target_value, monkeys, vars, current_guess + 1, max_guess)
    end
  end

  def p2() do
    monkeys = input() |> parse() |> munge_for_p2()
    # 10000 iterations is just a guess; could be smarter and stop when vars
    # is unchanged between iterations.
    {monkeys, vars} = Enum.reduce(1..10000, {monkeys, %{}}, fn _ix, acc ->
      calc_step(acc)
    end)
    {[{"root", {:eq, l, r}}], monkeys} = Enum.split_with(monkeys, fn {name, command} ->
      case name do
        "root" -> true
        _ -> false
      end
    end)
    # The l and r of the root element need to be equal; one is
    # defined, find it and set a var for the other to be the
    # same.
    vars = case Map.get(vars, l) do
      nil ->
        Map.put(vars, l, Map.get(vars, r))
      v ->
        Map.put(vars, r, v)
    end
    # This doesn't actually work... hmm...
    all_monkey_business = monkeys ++ inverse_monkeys(monkeys) ++ converse_monkeys(monkeys)
    calc({all_monkey_business, vars}, "humn")
  end
end
