defmodule D19 do
  def demo_input() do
    ~S"""
    Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
    Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
    """ |> String.trim()
  end

  def input(), do: File.read!("data/d19")

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn chunk ->
      "Blueprint " <> rest = chunk
      {_blueprint, ": Each ore robot costs " <> rest} = Integer.parse(rest)
      {ore, " ore. Each clay robot costs " <> rest} = Integer.parse(rest)
      {clay, " ore. Each obsidian robot costs " <> rest} = Integer.parse(rest)
      {obsidian_ore, " ore and " <> rest} = Integer.parse(rest)
      {obsidian_clay, " clay. Each geode robot costs " <> rest} = Integer.parse(rest)
      {geode_ore, " ore and " <> rest} = Integer.parse(rest)
      {geode_obsidian, " obsidian."} = Integer.parse(rest)
      [
        ore: [ore: ore],
        clay: [ore: clay],
        obsidian: [ore: obsidian_ore, clay: obsidian_clay],
        geode: [ore: geode_ore, obsidian: geode_obsidian]
      ]
    end)
  end

  def follow_blueprint(blueprint, quit_at) do
    follow_blueprint_impl(blueprint, 0, %{ore: 1, clay: 0, obsidian: 0, geode: 0}, %{ore: 0, clay: 0, obsidian: 0, geode: 0}, quit_at)
  end

  def add_mining_results(stores, robots) do
    Enum.reduce(robots, stores, fn {k, v}, stores ->
      Map.put(stores, k, Map.get(stores, k) + v)
    end)
  end

  def can_afford(blueprint, stores) do
    Enum.filter(blueprint, fn {_, costs} ->
      [] == Enum.filter(costs, fn {type, cost} ->
        if stores[type] >= cost do
          false
        else
          true
        end
      end)
    end)
  end

  def apply_heuristics(afforded) do
    case Enum.filter(afforded, fn {type, _} -> type == :geode end) do
      [_] = geode_only -> geode_only
      _ ->
        case Enum.filter(afforded, fn {type, _} -> type == :obsidian end) do
          [_] = obsidian_only -> obsidian_only
          _ -> afforded
        end
    end
  end

  def make_actions(blueprint, stores) do
    purchase_actions = can_afford(blueprint, stores)
    |> apply_heuristics()
    |> Enum.map(fn {type, costs} ->
      # Return a function that modifies robots and stores
      # in the appropriate way.
      fn robots, stores ->
        #IO.inspect {:possibility_func, robots, stores}
        # It's always +1 robot; it could never be more effective to
        # wait until you can afford 2 robots of the same type.
        {
          Map.put(robots, type, Map.get(robots, type) + 1),
          Enum.reduce(costs, stores, fn {type, cost}, stores ->
            Map.put(stores, type, Map.get(stores, type) - cost)
          end)
        } # |> IO.inspect
      end
    end)

    [fn robots, stores -> {robots, stores} end|purchase_actions]
  end

  def make_memo_key(blueprint, done_minutes, robots, stores, quit_at) do
    # Truncate the key a bit based on heuristics; if we have 3x more than
    # we need for any robot type, any further stores probably will give the
    # same result. (The 3x is based on trial and error with p1)
    truncated_stores = Enum.reduce(blueprint, stores, fn {robot_type, costs}, stores ->
      Enum.reduce(costs, stores, fn {type, cost}, stores ->
        Map.put(stores, type, min(stores[type], cost * 3))
      end)
    end)
    {blueprint, done_minutes, robots, truncated_stores, quit_at}
  end

  def follow_blueprint_impl(blueprint, done_minutes, robots, %{geode: geode_num}, quit_at) when done_minutes == quit_at do
    geode_num
  end
  def follow_blueprint_impl(blueprint, done_minutes, robots, stores, quit_at) do
    memo_key = make_memo_key(blueprint, done_minutes, robots, stores, quit_at)
    case Process.get(memo_key) do
      nil ->
        possible_actions = make_actions(blueprint, stores)
        #IO.inspect {:possible_actions, possible_actions}
        stores_after_harvesting = Enum.reduce(robots, stores, fn {type, count}, acc ->
          Map.put(acc, type, Map.get(acc, type) + count)
        end)
        #IO.inspect {:stores_after_harvesting, stores_after_harvesting}

        best = Enum.map(possible_actions, fn action ->
          {next_robots, next_stores} = action.(robots, stores_after_harvesting)
          follow_blueprint_impl(blueprint, done_minutes + 1, next_robots, next_stores, quit_at)
        end)
        |> Enum.sort(&>=/2)
        |> Enum.at(0)
        Process.put(memo_key, best)
        best
      val ->
        val
    end
  end

  def p1() do
    blueprints = input() |> parse()
    Enum.reduce(blueprints, {1, []}, fn blueprint, {number, results} ->
      IO.inspect "starting blueprint #{number}"
      result = follow_blueprint(blueprint, 24) * number
      IO.inspect "blueprint result was #{result}"
      {number + 1, [result|results]}
    end)
    |> elem(1)
    |> Enum.sum()
  end

  def p2() do
    blueprints = input() |> parse() |> Enum.take(3)
    Enum.reduce(blueprints, 1, fn blueprint, acc ->
      IO.inspect "starting blueprint"
      result = follow_blueprint(blueprint, 32)
      IO.inspect "blueprint result was #{result}"
      acc * result
    end)
  end
end
