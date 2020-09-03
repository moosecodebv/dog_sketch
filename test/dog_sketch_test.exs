defmodule DogSketchTest do
  use ExUnit.Case
  doctest DogSketch

  test "greets the world" do
    assert DogSketch.hello() == :world
  end
end
