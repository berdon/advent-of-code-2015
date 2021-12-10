defmodule Mix.Tasks.Day03 do
  @moduledoc ""
  use Mix.Task

  @shortdoc ""
  def run(_) do
    Mix.Task.run("app.start")

    response =
      HTTPoison.get!("https://adventofcode.com/2015/day/3/input", %{},
        hackney: [cookie: [Application.get_env(:aoc, :sessionCookie)]]
      )

    acc = [position: [x: 0, y: 0], visited: MapSet.new()]

    visited =
      Enum.reduce(String.to_charlist(response.body), acc, fn instr, acc ->
        position = acc[:position]

        visited =
          if !MapSet.member?(acc[:visited], position) do
            MapSet.put(acc[:visited], position)
          else
            acc[:visited]
          end

        position =
          case instr do
            ?^ -> [x: position[:x], y: position[:y] + 1]
            ?v -> [x: position[:x], y: position[:y] - 1]
            ?< -> [x: position[:x] - 1, y: position[:y]]
            ?> -> [x: position[:x] + 1, y: position[:y]]
          end

        [position: position, visited: visited]
      end)

    visitedNodes = MapSet.size(visited[:visited])

    IO.puts("Part 1: Total houses visited with egg-nogged elf driven santa is #{visitedNodes}")

    acc = [position: [x: 0, y: 0], visited: MapSet.new()]

    robotOneVisited =
      Enum.reduce(Enum.take_every(String.to_charlist(response.body), 2), acc, fn instr, acc ->
        position = acc[:position]

        visited =
          if !MapSet.member?(acc[:visited], position) do
            MapSet.put(acc[:visited], position)
          else
            acc[:visited]
          end

        position =
          case instr do
            ?^ -> [x: position[:x], y: position[:y] + 1]
            ?v -> [x: position[:x], y: position[:y] - 1]
            ?< -> [x: position[:x] - 1, y: position[:y]]
            ?> -> [x: position[:x] + 1, y: position[:y]]
          end

        [position: position, visited: visited]
      end)

    robotTwoVisited =
      Enum.reduce(
        Enum.take_every(Enum.drop(String.to_charlist(response.body), 1), 2),
        acc,
        fn instr, acc ->
          position = acc[:position]

          visited =
            if !MapSet.member?(acc[:visited], position) do
              MapSet.put(acc[:visited], position)
            else
              acc[:visited]
            end

          position =
            case instr do
              ?^ -> [x: position[:x], y: position[:y] + 1]
              ?v -> [x: position[:x], y: position[:y] - 1]
              ?< -> [x: position[:x] - 1, y: position[:y]]
              ?> -> [x: position[:x] + 1, y: position[:y]]
            end

          [position: position, visited: visited]
        end
      )

    visitedNodes = MapSet.size(MapSet.union(robotOneVisited[:visited], robotTwoVisited[:visited]))

    IO.puts("Part 2: Total houses visited with robo-santa is #{visitedNodes}")
  end
end
