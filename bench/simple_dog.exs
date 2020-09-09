alias DogSketch.{SimpleDog, ExactDog}

sd1 =
  Enum.reduce(1..10000, SimpleDog.new(error: 0.02), fn _x, sd ->
    SimpleDog.insert(sd, :rand.uniform(10000))
  end)

sd2 =
  Enum.reduce(1..10000, SimpleDog.new(error: 0.02), fn _x, sd ->
    SimpleDog.insert(sd, :rand.uniform(10000))
  end)

ed1 =
  Enum.reduce(1..10000, ExactDog.new(error: 0.02), fn _x, sd ->
    ExactDog.insert(sd, :rand.uniform(10000))
  end)

ed2 =
  Enum.reduce(1..10000, ExactDog.new(error: 0.02), fn _x, sd ->
    ExactDog.insert(sd, :rand.uniform(10000))
  end)

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
    end,
    "ExactDog.insert/2" => fn num ->
      ExactDog.insert(ed1, num)
    end,
    "ExactDog.merge/2" => fn _ ->
      ExactDog.merge(ed1, ed2)
    end,
    "ExactDog.quantile/2 50%" => fn _ ->
      ExactDog.quantile(ed1, 0.5)
    end,
    "ExactDog.quantile/2 90%" => fn _ ->
      ExactDog.quantile(ed1, 0.9)
    end,
    "ExactDog.quantile/2 99%" => fn _ ->
      ExactDog.quantile(ed1, 0.99)
    end
  },
  before_each: fn _ -> :rand.uniform(10000) end
)
