defmodule DogSketch.SimpleDog do
  defstruct data: %{}, gamma: 0, total: 0

  def new(opts \\ []) do
    err = Keyword.get(opts, :error, 0.02)
    gamma = (1 + err) / (1 - err)
    %__MODULE__{gamma: gamma}
  end

  def merge(%{gamma: g} = s1, %{gamma: g} = s2) do
    data = Map.merge(s1.data, s2.data, fn _k, val1, val2 -> val1 + val2 end)
    %__MODULE__{data: data, gamma: g, total: s1.total + s2.total}
  end

  def insert(s, val) do
    bin =
      (:math.log(val) / :math.log(s.gamma))
      |> Float.ceil()
      |> trunc()

    data = Map.update(s.data, bin, 1, fn x -> x + 1 end)

    %__MODULE__{s | data: data, total: s.total + 1}
  end

  def quantile(s, quantile) do
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

    2 * :math.pow(s.gamma, index) / (s.gamma + 1)
  end
end
