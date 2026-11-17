defmodule SimpleDogSketchTest do
  use ExUnit.Case
  doctest DogSketch

  alias DogSketch.{SimpleDog, ExactDog}

  use PropCheck

  property "quantile within error bounds of exact" do
    forall {error, values, quantile} <-
             {float(0.0, 1.0), non_empty(list(non_neg_float())), float(0.0, 1.0)} do
      sd_quantile =
        Enum.reduce(values, SimpleDog.new(error: error), fn val, acc ->
          SimpleDog.insert(acc, val)
        end)
        |> SimpleDog.quantile(quantile)

      exact_quantile =
        Enum.reduce(values, ExactDog.new(), fn val, acc ->
          ExactDog.insert(acc, val)
        end)
        |> ExactDog.quantile(quantile)

      abs(sd_quantile / exact_quantile - 1) <= error
    end
  end

  property "merging is lossless" do
    forall {error, values, quantile} <-
             {float(0.0, 1.0), non_empty(list(non_neg_float())), float(0.0, 1.0)} do
      sd_quantile =
        Enum.reduce(values, SimpleDog.new(error: error), fn val, acc ->
          SimpleDog.insert(acc, val)
        end)
        |> SimpleDog.quantile(quantile)

      merged_quantile =
        Enum.reduce(values, SimpleDog.new(error: error), fn val, acc ->
          new_sd = SimpleDog.new(error: error) |> SimpleDog.insert(val)
          SimpleDog.merge(new_sd, acc)
        end)
        |> SimpleDog.quantile(quantile)

      sd_quantile == merged_quantile
    end
  end

  property "inserting into a merged sketch is the same as inserting into an unmerged one" do
    forall {error, before_merge, after_merge} <-
             {float(0.0, 1.0), non_empty(list(non_neg_float())), non_empty(list(non_neg_float()))} do
      insert_all = fn sketch, values ->
        Enum.reduce(values, sketch, fn val, acc -> SimpleDog.insert(acc, val) end)
      end

      direct = insert_all.(SimpleDog.new(error: error), before_merge ++ after_merge)

      merged =
        SimpleDog.new(error: error)
        |> insert_all.(before_merge)
        |> SimpleDog.merge(SimpleDog.new(error: error))
        |> insert_all.(after_merge)

      merged == direct
    end
  end

  test "merge keeps the sketch usable for further inserts" do
    s1 = SimpleDog.new() |> SimpleDog.insert(10)
    s2 = SimpleDog.new() |> SimpleDog.insert(10)

    merged =
      SimpleDog.merge(s1, s2)
      |> then(fn s -> Enum.reduce(1..100, s, fn _, acc -> SimpleDog.insert(acc, 1000) end) end)

    assert_in_delta SimpleDog.quantile(merged, 0.5), 1000, 1000 * 0.02
  end
end
