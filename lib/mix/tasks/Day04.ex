defmodule Mix.Tasks.Day04 do
  @moduledoc ""
  use Mix.Task

  def mine(token, length) do
    mine(token, Enum.reduce(0..(length-1), "", fn _, acc -> "0" <> acc end), length)
  end

  def mine(token, prefix, index) do
    hash = :crypto.hash(:md5, token <> to_string(index)) |> Base.encode16()

    if String.starts_with?(hash, prefix) do
      index
    else
      mine(token, prefix, index + 1)
    end
  end

  @shortdoc ""
  def run(_) do
    Mix.Task.run("app.start")

    response =
      HTTPoison.get!("https://adventofcode.com/2015/day/4/input", %{},
        hackney: [cookie: [Application.get_env(:aoc, :sessionCookie)]]
      )

    adventCoinToken = hd(Enum.filter(String.split(response.body, "\n"), fn x -> x != "" end))

    hashWith5 = mine(adventCoinToken, 5)

    IO.puts("Part 1: Index producing a 5-0 prefixed hash is #{hashWith5}")

    hashWith6 = mine(adventCoinToken, 6)

    IO.puts("Part 2: Index producing a 6-0 prefixed hash is #{hashWith6}")
  end
end
