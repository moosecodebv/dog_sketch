defmodule ArrayDogSketchTest do
  use ExUnit.Case
  doctest DogSketch

  alias DogSketch.{ArrayDog, ExactDog}

  use PropCheck

  property "quantile within error bounds of exact" do
    forall {error, values, quantile} <-
             {float(0.0, 1.0), non_empty(list(non_neg_float())), float(0.0, 1.0)} do
      sd_quantile =
        Enum.reduce(values, ArrayDog.new(error: error), fn val, acc ->
          ArrayDog.insert(acc, val)
        end)
        |> ArrayDog.quantile(quantile)

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
        Enum.reduce(values, ArrayDog.new(error: error), fn val, acc ->
          ArrayDog.insert(acc, val)
        end)
        |> ArrayDog.quantile(quantile)

      merged_quantile =
        Enum.reduce(values, ArrayDog.new(error: error), fn val, acc ->
          new_sd = ArrayDog.new(error: error) |> ArrayDog.insert(val)
          ArrayDog.merge(new_sd, acc)
        end)
        |> ArrayDog.quantile(quantile)

      sd_quantile == merged_quantile
    end
  end
end
