defmodule Mix.Tasks.Day06 do
  @moduledoc ""
  use Mix.Task

  @spec updateGrid(
          tuple,
          atom | %{:x => non_neg_integer, :y => non_neg_integer, optional(any) => any},
          atom | %{:x => any, optional(any) => any},
          any
        ) :: tuple
  def updateGrid(grid, from, to, value) do
    updateGrid(grid, from, to, from, value)
  end

  @spec updateGrid(
          tuple,
          any,
          atom | %{:x => any, optional(any) => any},
          atom | %{:x => non_neg_integer, :y => non_neg_integer, optional(any) => any},
          any
        ) :: tuple
  def updateGrid(grid, from, to, loc, value) do
    current_value = elem(elem(grid, loc.y), loc.x)
    grid = put_elem(grid, loc.y, put_elem(elem(grid, loc.y), loc.x, cond do
      value == :on -> :on
      value == :off -> :off
      value == :toggle -> if current_value == :on do :off else :on end
    end))
    cond do
      loc.x == to.x && loc.y == to.y -> grid
      loc.x == to.x -> updateGrid(grid, from, to, %{:x => from.x, :y => loc.y + 1}, value)
      true -> updateGrid(grid, from, to, %{:x => loc.x + 1, :y => loc.y}, value)
    end
  end

  @spec nordicUpdateGrid(
          tuple,
          atom | %{:x => non_neg_integer, :y => non_neg_integer, optional(any) => any},
          atom | %{:x => any, optional(any) => any},
          any
        ) :: tuple
  def nordicUpdateGrid(grid, from, to, value) do
    nordicUpdateGrid(grid, from, to, from, value)
  end

  @spec nordicUpdateGrid(
          tuple,
          any,
          atom | %{:x => any, optional(any) => any},
          atom | %{:x => non_neg_integer, :y => non_neg_integer, optional(any) => any},
          any
        ) :: tuple
  def nordicUpdateGrid(grid, from, to, loc, value) do
    current_value = elem(elem(grid, loc.y), loc.x)
    grid = put_elem(grid, loc.y, put_elem(elem(grid, loc.y), loc.x, cond do
      value == :on -> current_value + 1
      value == :off -> if (current_value - 1) < 0 do 0 else current_value - 1 end
      value == :toggle -> current_value + 2
    end))
    cond do
      loc.x == to.x && loc.y == to.y -> grid
      loc.x == to.x -> nordicUpdateGrid(grid, from, to, %{:x => from.x, :y => loc.y + 1}, value)
      true -> nordicUpdateGrid(grid, from, to, %{:x => loc.x + 1, :y => loc.y}, value)
    end
  end

  @shortdoc ""
  def run(_) do
    debug = false
    size = 1000
    Mix.Task.run("app.start")

    response = if !debug do
      HTTPoison.get!("https://adventofcode.com/2015/day/6/input", %{},
        hackney: [cookie: [Application.get_env(:aoc, :sessionCookie)]]
      )
    else
      %{:body => "turn on 0,0 through 9,9\ntoggle 0,0 through 9,0\nturn off 4,4 through 5,5"}
    end
    data = String.split(response.body, "\n")
           |> Enum.filter(&(&1 != ""))
    grid = Enum.reduce(0..(size-1), {}, fn _, acc1 ->
      Tuple.append(acc1, List.to_tuple(Enum.reduce(0..(size-1), [], fn _, acc2 -> acc2 ++ [:off] end)))

    end)
    grid = data
      |> Enum.map(&(String.split(&1, ~r/(\,|\ through\ )/)))
      |> Enum.map(&(List.to_tuple(&1)))
      |> Enum.map(fn tokens ->
        first = elem(tokens, 0)
        cond do
          String.starts_with?(first, "turn on") ->
            %{ :command => :on,
               :from => %{:x => String.to_integer(String.slice(first, 8..-1)), :y => String.to_integer(elem(tokens, 1))},
               :to => %{:x => String.to_integer(elem(tokens, 2)), :y => String.to_integer(elem(tokens, 3))}}
          String.starts_with?(first, "turn off") ->
            %{ :command => :off,
               :from => %{:x => String.to_integer(String.slice(first, 9..-1)), :y => String.to_integer(elem(tokens, 1))},
               :to => %{:x => String.to_integer(elem(tokens, 2)), :y => String.to_integer(elem(tokens, 3))}}
          String.starts_with?(first, "toggle") ->
            %{ :command => :toggle,
               :from => %{:x => String.to_integer(String.slice(first, 7..-1)), :y => String.to_integer(elem(tokens, 1))},
               :to => %{:x => String.to_integer(elem(tokens, 2)), :y => String.to_integer(elem(tokens, 3))}}
          true -> throw("Eh?")
        end
      end)
      |> Enum.reduce(grid, fn c, acc ->
        updateGrid(acc, c.from, c.to, c.command)
      end)

    count = Enum.reduce(Tuple.to_list(grid), 0, fn row, acc ->
      acc + Enum.reduce(Tuple.to_list(row), 0, fn value, acc2 -> acc2 + if value == :on do 1 else 0 end end)
    end)

    IO.puts("Part 1: #{count} lights lit")

    grid = Enum.reduce(0..(size-1), {}, fn _, acc1 ->
      Tuple.append(acc1, List.to_tuple(Enum.reduce(0..(size-1), [], fn _, acc2 -> acc2 ++ [0] end)))
    end)
    grid = data
      |> Enum.map(&(String.split(&1, ~r/(\,|\ through\ )/)))
      |> Enum.map(&(List.to_tuple(&1)))
      |> Enum.map(fn tokens ->
        first = elem(tokens, 0)
        cond do
          String.starts_with?(first, "turn on") ->
            %{ :command => :on,
               :from => %{:x => String.to_integer(String.slice(first, 8..-1)), :y => String.to_integer(elem(tokens, 1))},
               :to => %{:x => String.to_integer(elem(tokens, 2)), :y => String.to_integer(elem(tokens, 3))}}
          String.starts_with?(first, "turn off") ->
            %{ :command => :off,
               :from => %{:x => String.to_integer(String.slice(first, 9..-1)), :y => String.to_integer(elem(tokens, 1))},
               :to => %{:x => String.to_integer(elem(tokens, 2)), :y => String.to_integer(elem(tokens, 3))}}
          String.starts_with?(first, "toggle") ->
            %{ :command => :toggle,
               :from => %{:x => String.to_integer(String.slice(first, 7..-1)), :y => String.to_integer(elem(tokens, 1))},
               :to => %{:x => String.to_integer(elem(tokens, 2)), :y => String.to_integer(elem(tokens, 3))}}
          true -> throw("Eh?")
        end
      end)
      |> Enum.reduce(grid, fn c, acc ->
        nordicUpdateGrid(acc, c.from, c.to, c.command)
      end)

    brightness = Enum.reduce(Tuple.to_list(grid), 0, fn row, acc ->
      acc + Enum.reduce(Tuple.to_list(row), 0, fn value, acc2 -> acc2 + value end)
    end)

    IO.puts("Part 2: Total bulb brightness is #{brightness}")
  end
end
