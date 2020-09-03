defmodule Mix.Tasks.Proper do
  use Mix.Task

  def run([]) do
    "test/**/*_prop.exs"
    |> Path.wildcard()
    |> Kernel.ParallelRequire.files()
  end
end
