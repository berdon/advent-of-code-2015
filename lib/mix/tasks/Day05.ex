defmodule Mix.Tasks.Day05 do
  @moduledoc ""
  use Mix.Task

  @shortdoc ""
  def run(_) do
    Mix.Task.run("app.start")

    response =
      HTTPoison.get!("https://adventofcode.com/2015/day/5/input", %{},
        hackney: [cookie: [Application.get_env(:aoc, :sessionCookie)]]
      )
    data = String.split(response.body, "\n") |> Enum.filter(fn x -> x != "" end)

    # Sigh. Should have used regex ¯\_(ツ)_/¯
    niceStrings = Enum.map(data, fn x -> [
        line: x,
        vowels: String.to_charlist(x) |> Enum.filter(fn c -> c == ?a || c == ?e || c == ?i || c == ?o || c == ?u end) |> to_string(),
        duplicates: String.to_charlist(x) |> Enum.chunk_every(2, 1, :discard) |> Enum.filter(fn x -> length(x) > length(Enum.dedup(x)) end),
        exclusions: String.to_charlist(x) |> Enum.chunk_every(2, 1, :discard)
                                          |> Enum.map(fn x -> to_string(x) end )
                                          |> Enum.filter(fn x -> x == "ab" || x == "cd" || x == "pq" || x == "xy" end)
      ]
    end) |> Enum.filter(fn x -> String.length(x[:vowels]) >= 3 end)
         |> Enum.filter(fn x -> length(x[:duplicates]) > 0 end)
         |> Enum.filter(fn x -> length(x[:exclusions]) == 0 end)
         |> length()

    IO.puts("Part 1: Number of nice strings is #{niceStrings}")

    niceStrings = (Enum.map(data, fn x -> [
        line: x,
        duplicates: Map.to_list(elem(Keyword.fetch(to_charlist(x)
                    |> Enum.chunk_every(2, 1, :discard)
                    |> Enum.map(fn chunk -> to_string(chunk) end)
                    |> Enum.reduce([last: nil, set: Map.new()], fn c, acc ->
                        cond do
                          acc[:last] != nil && length(Enum.dedup(to_charlist(acc[:last] <> c))) == 1 -> [last: nil, set: acc[:set]]
                          true -> [last: c, set: Map.update(acc[:set], c, 1, fn cur -> cur + 1 end)]
                        end
                       end), :set), 1))
                    |> Enum.filter(fn x -> elem(x, 1) > 1 end)
                    |> Enum.map(fn x -> elem(x, 0) end),
        triplicate: String.to_charlist(x)
                    |> Enum.chunk_every(3, 1, :discard)
                    |> Enum.filter(fn chunk ->
                      length(chunk |> Enum.take_every(2) |> Enum.dedup()) == 1
                      || length(chunk |> Enum.dedup()) == 1
                    end)
                    |> Enum.map(fn x -> x |> to_string() end)
      ]
    end) |> Enum.filter(fn x -> length(x[:duplicates]) > 0 end)
         |> Enum.filter(fn x -> length(x[:triplicate]) > 0 end)
         |> length())

    IO.puts("Part 2: Number of nice strings is #{niceStrings}")
  end
end
