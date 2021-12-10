defmodule Mix.Tasks.Day01 do
  @moduledoc ""
  use Mix.Task

  @shortdoc ""
  def run(_) do
    Mix.Task.run("app.start")

    response =
      HTTPoison.get!("https://adventofcode.com/2015/day/1/input", %{},
        hackney: [
          cookie: [Application.get_env(:aoc, :sessionCookie)]
        ]
      )

    data = String.to_charlist(response.body)

    data =
      Enum.map(data, fn
        x when x == ?( -> 1
        _ -> -1
      end)

    sum = Enum.reduce(data, 0, fn ele, acc -> acc + ele end)
    IO.puts("Part 1: Target floor is the #{sum}th floor")

    basement =
      Enum.reduce_while(data, {0, 0}, fn x, acc ->
        level = elem(acc, 0) + x
        position = elem(acc, 1) + 1
        if level != -1, do: {:cont, {level, position}}, else: {:halt, {level, position}}
      end)

    IO.puts("Part 2: Hit the basement at level position #{elem(basement, 1)}")
  end
end
