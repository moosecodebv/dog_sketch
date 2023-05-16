defmodule DogSketch.ExactDog do
  defstruct data: %{}, total: 0

  def new(_opts \\ []) do
    %__MODULE__{}
  end

  def merge(s1, s2) do
    data = Map.merge(s1.data, s2.data, fn _k, val1, val2 -> val1 + val2 end)
    %__MODULE__{data: data, total: s1.total + s2.total}
  end

  def insert(s, val) do
    data = Map.update(s.data, val, 1, fn x -> x + 1 end)

    %__MODULE__{s | data: data, total: s.total + 1}
  end

  def quantile(s, quantile) when quantile >= 0 and quantile <= 1 do
    total_quantile = s.total * quantile

    index =
      Enum.sort_by(s.data, fn {key, _v} -> key end)
      |> Enum.reduce_while(0, fn {key, val}, total ->
        if total + val >= total_quantile do
          {:halt, key}
        else
          {:cont, total + val}
        end
      end)

    index
  end
end
