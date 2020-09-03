defmodule MemoryHelper do
  def memory_kb(term) do
    (:erts_debug.flat_size(term) / 8.0 / :math.pow(2, 10))
    |> Float.round(1)
  end

  def wire_kb(term) do
    (byte_size(:erlang.term_to_binary(term)) / :math.pow(2, 10))
    |> Float.round(1)
  end
end

alias DogSketch.{SimpleDog, ExactDog}

sd =
  Enum.reduce(1..100_000, SimpleDog.new(error: 0.02), fn _x, sd ->
    SimpleDog.insert(sd, :rand.uniform(10000))
  end)

ed =
  Enum.reduce(1..100_000, ExactDog.new(), fn _x, sd ->
    ExactDog.insert(sd, :rand.uniform(10000))
  end)

IO.inspect(MemoryHelper.memory_kb(sd), label: "100k inserts SimpleDog 2% error (kb)")
IO.inspect(MemoryHelper.memory_kb(ed), label: "100k inserts ExactDog (kb)")
