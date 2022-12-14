defmodule D7 do
  def demo_input() do
    ~S"""
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
    |> String.trim()
  end

  def input(), do: File.read!("data/d7")

  def parse_p1(input) do
    commands_with_output = String.split(input, "$ ")
    commands_with_output
    |> Enum.map(fn str ->
      [command|output_lines] = str |> String.trim() |> String.split("\n")
      {command, output_lines}
    end)
    |> Enum.filter(fn {command, output_lines} -> command != "" end)
    |> Enum.map(fn {command, output_lines} ->
      {command, Enum.flat_map(output_lines, fn line ->
        [size, name] = String.split(line, " ")
        case size do
          "dir" -> [{:dir, name}]
          _ -> [{Integer.parse(size) |> elem(0), name}]
        end
      end)}
    end)
    |> Enum.map(fn {command, files} ->
      case command do
        "ls" -> {:ls, files}
        "cd " <> rest -> {{:cd, rest}, files}
      end
    end)
  end

  def calc_p1(commands) do
    Enum.reduce(commands, {["/"], %{}}, fn {command, files}, {path_in, sizes} ->
      case command do
        :ls ->
          sub_dirs = Enum.reduce(files, [], fn {size, name}, acc ->
            case size do
              :dir ->
                [[name|path_in]|acc]
              _ ->
                acc
            end
          end)
          own_size = Enum.reduce(files, 0, fn {size, _name}, acc ->
            case size do
              :dir -> acc
              _ -> acc + size
            end
          end)
          {path_in, Map.put(sizes, path_in, {own_size, sub_dirs})}
        {:cd, path} ->
          case path do
            "/" ->
              {["/"], sizes}
            ".." ->
              [_|prev_path] = path_in
              {prev_path, sizes}
            _ ->
              {[path|path_in], sizes}
          end
      end
    end)
  end

  def final_size(source, path, acc) do
    case Map.get(source, path) do
      {own_size, []} ->
        acc + own_size
      {own_size, sub_dirs} ->
        own_size + acc + Enum.sum(Enum.map(sub_dirs, fn sub -> final_size(source, sub, 0) end))
    end
  end

  def final_sizes_p1(own_sizes_and_dirs) do
    Enum.map(own_sizes_and_dirs, fn {path, {own_size, sub_dirs}} ->
      {path, final_size(own_sizes_and_dirs, path, 0)}
    end)
  end

  def p1() do
    D7.input |> D7.parse_p1 |> D7.calc_p1 |> elem(1) |> D7.final_sizes_p1()
    |> Enum.filter(fn {_path, size} -> size <= 100000 end)
    |> Enum.reduce(0, fn {_path, size}, acc -> acc + size end)
  end

  @total_size 70000000
  @needed_free 30000000

  def p2() do
    [root_size|sizes] = D7.input |> D7.parse_p1 |> D7.calc_p1 |> elem(1) |> D7.final_sizes_p1()
    |> Enum.sort_by(&(&1 |> elem(1)), &>=/2)

    current_free = @total_size - elem(root_size, 1)

    Enum.find(Enum.reverse(sizes), fn {_path, size} ->
      current_free + size >= @needed_free
    end)
    |> elem(1)
  end
end
