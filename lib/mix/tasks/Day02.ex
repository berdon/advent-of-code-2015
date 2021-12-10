defmodule Mix.Tasks.Day02 do
  @moduledoc ""
  use Mix.Task

  @shortdoc ""
  def run(_) do
    Mix.Task.run("app.start")

    response =
      HTTPoison.get!("https://adventofcode.com/2015/day/2/input", %{},
        hackney: [cookie: [Application.get_env(:aoc, :sessionCookie)]]
      )

    lines = Enum.filter(String.split(response.body, "\n"), fn line -> line != "" end)

    data =
      Enum.map(lines, fn line ->
        List.to_tuple(
          Enum.map(String.split(line, "x"), fn dim -> elem(Integer.parse(dim), 0) end)
        )
      end)

    areas =
      Enum.map(data, fn dimensions ->
        length = elem(dimensions, 0)
        width = elem(dimensions, 1)
        height = elem(dimensions, 2)
        area = 2 * length * width + 2 * width * height + 2 * height * length
        smallest_side = min(length * width, min(width * height, height * length))

        {[length: length, width: width, height: height], area, smallest_side,
         area + smallest_side}
      end)

    wrappingPaper = Enum.reduce(areas, 0, fn x, acc -> elem(x, 3) + acc end)

    IO.puts("Part 1: Total wrapping paper area is #{wrappingPaper} sq. ft")

    totalFeetOfRibbon =
      Enum.reduce(
        Enum.map(areas, fn x ->
          dim = elem(x, 0)
          dimensions = Enum.sort(List.flatten(Keyword.values(dim)))
          perimeter = Enum.reduce(Enum.drop(dimensions, -1), 0, fn x, acc -> 2 * x + acc end)
          volume = Enum.reduce(Keyword.values(dim), 1, fn x, acc -> x * acc end)
          {perimeter, volume, perimeter + volume}
        end),
        0,
        fn x, acc -> elem(x, 2) + acc end
      )

    IO.puts("Part 2: Total feet of ribbon required is #{}")
  end
end
