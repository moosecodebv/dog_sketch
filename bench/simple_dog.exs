alias DogSketch.{SimpleDog, ExactDog}

sd1 =
  Enum.reduce(1..10000, SimpleDog.new(error: 0.02), fn _x, sd ->
    SimpleDog.insert(sd, :rand.uniform(10000))
  end)

sd2 =
  Enum.reduce(1..10000, SimpleDog.new(error: 0.02), fn _x, sd ->
    SimpleDog.insert(sd, :rand.uniform(10000))
  end)

ed = ExactDog.new()

Benchee.run(
  %{
    "SimpleDog.insert/2" => fn num ->
      SimpleDog.insert(sd1, num)
    end,
    "SimpleDog.merge/2" => fn _ ->
      SimpleDog.merge(sd1, sd2)
    end,
    "SimpleDog.quantile/2 50%" => fn _ ->
      SimpleDog.quantile(sd1, 0.5)
    end,
    "SimpleDog.quantile/2 90%" => fn _ ->
      SimpleDog.quantile(sd1, 0.9)
    end,
    "SimpleDog.quantile/2 99%" => fn _ ->
      SimpleDog.quantile(sd1, 0.99)
    end
  },
  before_each: fn _ -> :rand.uniform(10000) end
)
