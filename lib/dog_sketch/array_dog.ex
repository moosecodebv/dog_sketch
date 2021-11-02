defmodule DogSketch.ArrayDog do
  defstruct data_pos: :array.new(default: 0, size: 400),
            data_neg: :array.new(default: 0, size: 400),
            gamma: 0,
            total: 0,
            inv_log_gamma: 0

  def new(opts \\ []) do
    err = Keyword.get(opts, :error, 0.02)
    gamma = (1 + err) / (1 - err)
    inv_log_gamma = 1.0 / :math.log(gamma)
    %__MODULE__{gamma: gamma, inv_log_gamma: inv_log_gamma}
  end

  def insert(s, val) when val > 0 do
    bin =
      (:math.log(val) * s.inv_log_gamma)
      |> ceil()

    insert_bin(s, bin)
  end

  defp insert_bin(s, bin) when bin >= 0 do
    existing = :array.get(bin, s.data_pos)

    data_pos = :array.set(bin, existing + 1, s.data_pos)
    %{s | data_pos: data_pos, total: s.total + 1}
  end

  defp insert_bin(s, bin) when bin < 0 do
    existing = :array.get(-bin, s.data_neg)

    data_neg = :array.set(-bin, existing + 1, s.data_neg)
    %{s | data_neg: data_neg, total: s.total + 1}
  end

  def merge(%{gamma: g} = s1, %{gamma: g} = s2) do
    data_pos =
      :array.sparse_foldl(
        fn key, val, data_pos ->
          existing = :array.get(key, data_pos)
          :array.set(key, existing + val, data_pos)
        end,
        s1.data_pos,
        s2.data_pos
      )

    data_neg =
      :array.sparse_foldl(
        fn key, val, data_neg ->
          existing = :array.get(key, data_neg)
          :array.set(key, existing + val, data_neg)
        end,
        s1.data_neg,
        s2.data_neg
      )

    %__MODULE__{data_pos: data_pos, data_neg: data_neg, gamma: g, total: s1.total + s2.total}
  end

  def quantile(s, quantile) when quantile >= 0 and quantile <= 1 do
    total_quantile = s.total * quantile

    list =
      :array.sparse_foldr(
        fn key, val, data ->
          [{key, val} | data]
        end,
        [],
        s.data_pos
      )

    list =
      :array.sparse_foldl(
        fn key, val, data ->
          [{-key, val} | data]
        end,
        list,
        s.data_neg
      )

    index =
      list
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
