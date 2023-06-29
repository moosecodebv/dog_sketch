defmodule DogSketch.SimpleDog do
  defstruct data: %{}, gamma: 0, total: 0, inv_log_gamma: 0

  def new(opts \\ []) do
    err = Keyword.get(opts, :error, 0.02)
    gamma = (1 + err) / (1 - err)
    inv_log_gamma = 1.0 / :math.log(gamma)
    %__MODULE__{gamma: gamma, inv_log_gamma: inv_log_gamma}
  end

  def merge(%{gamma: g, inv_log_gamma: i} = s1, %{gamma: g} = s2) do
    data = Map.merge(s1.data, s2.data, fn _k, val1, val2 -> val1 + val2 end)
    %__MODULE__{data: data, gamma: g, total: s1.total + s2.total, inv_log_gamma: i}
  end

  def insert(s, val) when val > 0 do
    bin = ceil(:math.log(val) * s.inv_log_gamma)

    data = Map.update(s.data, bin, 1, fn x -> x + 1 end)

    %__MODULE__{s | data: data, total: s.total + 1}
  end

  def to_list(%{data: data, gamma: gamma}) do
    Enum.map(data, fn {key, val} ->
      {2 * :math.pow(gamma, key) / (gamma + 1), val}
    end)
  end

  def quantile(%{total: 0}, _), do: nil

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

    2 * :math.pow(s.gamma, index) / (s.gamma + 1)
  end

  def count(%{total: total}), do: total
end
