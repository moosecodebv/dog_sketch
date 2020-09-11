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
end
