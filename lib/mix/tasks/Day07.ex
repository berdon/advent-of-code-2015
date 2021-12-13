defmodule Mix.Tasks.Day07 do
  @moduledoc ""
  use Mix.Task

  def addTwoOperandInstruction(ctx, type, tokens) do
    inputOne = elem(tokens, 0)
    inputTwo = elem(tokens, 1)
    output = elem(tokens, 2)

    # Generate a transient operation gate for the actual operation
    gateName = "gate_#{ctx.gateCount}"
    ctx = %{ ctx |
      :graph => Map.update(ctx.graph, gateName, %{ :type => type, :to => [output], :inputs => [] }, fn c -> %{ c | :type => type, :to => c.to ++ [output], :inputs => [] } end),
      :gateCount => ctx.gateCount + 1 }

    # Add a vertex either for an inbound signal (from another vertex) or a transient vertex created for the input
    ctx = if Regex.match?(~r/^[a-zA-Z]*$/, inputOne) do
      graph = Map.update(ctx.graph, inputOne, %{ :type => :wire, :to => [gateName] }, fn c -> %{ c | :type => :wire, :to => c.to ++ [gateName] } end)
      graph = Map.update(graph, gateName, %{}, fn c -> %{ c | :inputs => c.inputs ++ [inputOne] } end)
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount }
    else
      wireName = "wire_#{ctx.wireCount}"
      graph = Map.put_new(ctx.graph, wireName, %{ :type => :value, :to => [gateName], :value => String.to_integer(inputOne) })
      graph = Map.update(graph, gateName, %{}, fn c -> %{ c | :inputs => c.inputs ++ [wireName] } end)
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount + 1 }
    end

    # Add a vertex either for an inbound signal (from another vertex) or a transient vertex created for the input
    ctx = if Regex.match?(~r/^[a-zA-Z]*$/, inputTwo) do
      graph = Map.update(ctx.graph, inputTwo, %{ :type => :wire, :to => [gateName] }, fn c -> %{ c | :type => :wire, :to => c.to ++ [gateName] } end)
      graph = Map.update(graph, gateName, %{}, fn c -> %{ c | :inputs => c.inputs ++ [inputTwo] } end)
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount }
    else
      wireName = "wire_#{ctx.wireCount}"
      graph = Map.put_new(ctx.graph, wireName, %{ :type => :value, :to => [gateName], :value => String.to_integer(inputTwo) })
      graph = Map.update(graph, gateName, %{}, fn c -> %{ c | :inputs => c.inputs ++ [wireName] } end)
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount + 1 }
    end

    # Add the output vertex if it doesn't exist
    ctx = if !Map.has_key?(ctx.graph, output) do
      %{ ctx | :graph => Map.put_new(ctx.graph, output, %{ :type => :wire, :to => [] }) }
    else
      ctx
    end

    ctx
  end

  def addOneOperandInstruction(ctx, type, tokens) do
    inputOne = elem(tokens, 1)
    output = elem(tokens, 2)

    # Generate a transient operation gate for the actual operation
    gateName = "gate_#{ctx.gateCount}"
    ctx = %{ ctx |
      :graph => Map.update(ctx.graph, gateName, %{ :type => type, :to => [output], :inputs => [] }, fn c -> %{ :type => type, :to => c.to ++ [output], :inputs => [] } end),
      :gateCount => ctx.gateCount + 1 }

    # Add a vertex either for an inbound signal (from another vertex) or a transient vertex created for the input
    ctx = if Regex.match?(~r/^[a-zA-Z]*$/, inputOne) do
      graph = Map.update(ctx.graph, inputOne, %{ :type => :wire, :to => [gateName] }, fn c -> %{ c | :type => :wire, :to => c.to ++ [gateName] } end)
      graph = Map.update(graph, gateName, %{}, fn c -> %{ c | :inputs => c.inputs ++ [inputOne] } end)
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount }
    else
      wireName = "wire_#{ctx.wireCount}"
      graph = Map.put_new(ctx.graph, wireName, %{ :type => :value, :to => [gateName], :value => String.to_integer(inputOne) })
      graph = Map.update(graph, gateName, %{}, fn c -> %{ c | :inputs => c.inputs ++ [wireName] } end)
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount + 1 }
    end

    # Add the output vertex if it doesn't exist
    ctx = if !Map.has_key?(ctx.graph, output) do
      %{ ctx | :graph => Map.put_new(ctx.graph, output, %{ :type => :wire, :to => [] }) }
    else
      ctx
    end

    ctx
  end

  def addAssignInstruction(ctx, tokens) do
    value = elem(tokens, 0)
    output = elem(tokens, 1)

    # Add a vertex either for an inbound signal (from another vertex) or a transient vertex created for the input
    ctx = if Regex.match?(~r/^[a-zA-Z]*$/, value) do
      graph = Map.update(ctx.graph, value, %{ :type => :wire, :to => [output] }, fn c -> %{ c | :to => c.to ++ [output] } end)
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount }
    else
      graph = Map.put_new(ctx.graph, "wire_#{ctx.wireCount}", %{ :type => :value, :to => [output], :value => String.to_integer(value) })
      %{ ctx | :graph => graph, :wireCount => ctx.wireCount + 1 }
    end

    # Add the output vertex if it doesn't exist
    ctx = if !Map.has_key?(ctx.graph, output) do
      %{ ctx | :graph => Map.put_new(ctx.graph, output, %{ :type => :wire, :to => [] }) }
    else
      ctx
    end

    ctx
  end

  @spec determineValueAt(map, map, map, String.t) ::  %{ value: integer, values: map }
  def determineValueAt(wiring, revWiring, values, at) do
    vertex = Map.get(wiring, at)
    inputs = List.to_tuple(if Map.has_key?(vertex, :inputs) do vertex.inputs else Map.get(revWiring, at, []) end)

    cond do
      # Return the memoized value if available
      Map.has_key?(values, at) ->
        %{ :value => Map.get(values, at), :values => values }
      # Final recursive state; memoize the vertex value and return it
      vertex.type == :value || Map.has_key?(vertex, :value) ->
        %{ :value => vertex.value, :values => Map.update(values, at, vertex.value, fn _ -> vertex.value end) }
      # Transient wire likely fed by a value vertex
      vertex.type == :wire ->
        determineValueAt(wiring, revWiring, values, elem(inputs, 0))
      # Grab the input values and perform the bitwise AND operation
      vertex.type == :and ->
        inputOneValue = determineValueAt(wiring, revWiring, values, elem(inputs, 0))
        inputTwoValue = determineValueAt(wiring, revWiring, inputOneValue.values, elem(inputs, 1))
        result = Bitwise.band(inputOneValue.value, inputTwoValue.value)
        # Elixir doesn't seem to support unsigned/fixed integers?
        result = if result >= 0 do result else 65536 + result end
        values = Map.update(inputTwoValue.values, at, result, fn _ -> result end)
        %{ :value => result, :values => values }
      # Grab the input values and perform the bitwise OR operation
      vertex.type == :or ->
        inputOneValue = determineValueAt(wiring, revWiring, values, elem(inputs, 0))
        inputTwoValue = determineValueAt(wiring, revWiring, inputOneValue.values, elem(inputs, 1))
        result = Bitwise.bor(inputOneValue.value, inputTwoValue.value)
        # Elixir doesn't seem to support unsigned/fixed integers?
        result = if result >= 0 do result else 65536 + result end
        values = Map.update(inputTwoValue.values, at, result, fn _ -> result end)
        %{ :value => result, :values => values }
      # Grab the input value and perform the bitwise NOT operation
      vertex.type == :not ->
        inputOneValue = determineValueAt(wiring, revWiring, values, elem(inputs, 0))
        result = Bitwise.bnot(inputOneValue.value)
        # Elixir doesn't seem to support unsigned/fixed integers?
        result = if result >= 0 do result else 65536 + result end
        values = Map.update(inputOneValue.values, at, result, fn _ -> result end)
        %{ :value => result, :values => values }
      # Grab the input values and perform the bitwise LSHIFT operation
      vertex.type == :lshift ->
        inputOneValue = determineValueAt(wiring, revWiring, values, elem(inputs, 0))
        inputTwoValue = determineValueAt(wiring, revWiring, inputOneValue.values, elem(inputs, 1))
        result = Bitwise.bsl(inputOneValue.value, inputTwoValue.value)
        # Elixir doesn't seem to support unsigned/fixed integers?
        result = if result >= 0 do result else 65536 + result end
        values = Map.update(inputTwoValue.values, at, result, fn _ -> result end)
        %{ :value => result, :values => values }
      # Grab the input values and perform the bitwise RSHIFT operation
      vertex.type == :rshift ->
        inputOneValue = determineValueAt(wiring, revWiring, values, elem(inputs, 0))
        inputTwoValue = determineValueAt(wiring, revWiring, inputOneValue.values, elem(inputs, 1))
        result = Bitwise.bsr(inputOneValue.value, inputTwoValue.value)
        # Elixir doesn't seem to support unsigned/fixed integers?
        result = if result >= 0 do result else 65536 + result end
        values = Map.update(inputTwoValue.values, at, result, fn _ -> result end)
        %{ :value => result, :values => values }
      true -> throw("Unknown vertex type")
    end
  end

  @shortdoc ""
  def run(_) do
    debug = false
    Mix.Task.run("app.start")

    data = if !debug do
      String.split(HTTPoison.get!("https://adventofcode.com/2015/day/7/input", %{},
        hackney: [cookie: [Application.get_env(:aoc, :sessionCookie)]]
      ).body, "\n")
    else
      [
        "123 -> x",
        "456 -> y",
        "x AND y -> d",
        "x OR y -> e",
        "x LSHIFT 2 -> f",
        "y RSHIFT 2 -> g",
        "NOT x -> h",
        "NOT y -> i",
      ]
    end
    wiring = (data
    |> Enum.filter(&(&1 != ""))
    |> Enum.reduce(%{ :graph => Map.new(), :gateCount => 0, :wireCount => 0 }, fn line, ctx ->
      # Iterate through each command and add vertices
      cond do
        String.contains?(line, "AND") -> addTwoOperandInstruction(ctx, :and, line |> String.split(~r/( AND | \-\> )/) |> List.to_tuple())
        String.contains?(line, "OR") -> addTwoOperandInstruction(ctx, :or, line |> String.split(~r/( OR | \-\> )/) |> List.to_tuple())
        String.contains?(line, "LSHIFT") -> addTwoOperandInstruction(ctx, :lshift, line |> String.split(~r/( LSHIFT | \-\> )/) |> List.to_tuple())
        String.contains?(line, "RSHIFT") -> addTwoOperandInstruction(ctx, :rshift, line |> String.split(~r/( RSHIFT | \-\> )/) |> List.to_tuple())
        String.contains?(line, "NOT") -> addOneOperandInstruction(ctx, :not, line |> String.split(~r/(NOT | \-\> )/) |> List.to_tuple())
        true -> addAssignInstruction(ctx, line |> String.split(~r/ \-\> /) |> List.to_tuple())
      end
    end))

    # Generate a graph with outputs pointing to their inputs used to reverse lookup inputs
    # Note: This isn't really used as I later added the mapping to most operation vertices
    # Note Note: I didn't fully add the reverse mapping to the transient operations so this
    # is still being used for now.
    revWiring = Map.map(wiring.graph, fn { _, value } -> value end) |> Enum.reduce(Map.new(), fn { key, value }, revWiring ->
      value.to |> Enum.reduce(revWiring, fn vertex, revWiring ->
        Map.update(revWiring, vertex, [key], fn existing -> existing ++ [key] end)
      end)
    end)

    # Recursively determine the output value at "a"
    aValue = determineValueAt(wiring.graph, revWiring, Map.new(), "a")

    IO.puts("Part 1: Output on wire A is #{aValue.value}")

    # Grab the generated input gate for b
    inputForB = hd(Map.get(revWiring, "b"))

    # Update the value for the "a" input gate
    updatedGraph = Map.update!(wiring.graph, inputForB, fn c -> Map.put(c, :value, aValue.value) end)

    # Determine the new a value
    aValue = determineValueAt(updatedGraph, revWiring, Map.new(), "a")

    IO.puts("Part 1: Output on wire A is #{aValue.value}")
  end
end
