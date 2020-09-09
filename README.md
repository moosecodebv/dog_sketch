# DogSketch

DogSketch lets you trade accuracy for speed and memory usage while calculating percentiles.

DogSketch is an implementation of the DDSketch algorithm, described in [this paper](papers/p2195-masson.pdf). It originated at DataDog.

## Examples

This library includes an "exact" implementation that can be compared against for the purposes of comparison (and property tests).

Note: the `SimpleDog` implementation does not give any guarantees of memory boundedness, which the full DDSketch algorithm does. Adding this should not be difficult, if you need it then please contribute, PRs are welcome!

```elixir
iex(1)> alias DogSketch.{ExactDog, SimpleDog}
[DogSketch.ExactDog, DogSketch.SimpleDog]
iex(2)> ed = ExactDog.new
%DogSketch.ExactDog{data: %{}, total: 0}
iex(5)> sd = SimpleDog.new(error: 0.04)
%DogSketch.SimpleDog{data: %{}, gamma: 1.0833333333333335, total: 0}
```

We have specified for the `SimpleDog` a maximum relative error rate of 4%.

Now let's add the numbers 1 to 10000 to the sketches and compare.

```elixir
iex(6)> sd = Enum.reduce(1..10000, sd, fn x, sd -> SimpleDog.insert(sd, x) end)
...
iex(7)> ed = Enum.reduce(1..10000, ed, fn x, ed -> ExactDog.insert(ed, x) end)
iex(8)> SimpleDog.quantile(sd, 0.5)
5032.880315534522
iex(9)> ExactDog.quantile(ed, 0.5)
5000
```

`5032/5000 = 1.0064`, or 0.64% error, which is well under the 4% error that we specified.

DDSketch is also fully mergeable, which is very useful in a distributed context. One might track web request response times on each node and aggregate the results later.

```elixir
iex(10)> SimpleDog.merge(sd1, sd2)
```

## Benchmarks

Artificial benchmarks (see [./bench](bench)) a 46x improvement in memory usage (0.1kb vs 4.6kb) for 2% relative error.

While ExactDog can do inserts 1.4x faster than SimpleDog, `SimpleDog.insert/2` is still capable of more than 2 million inserts per second, which should be fast enough for just about anything.

On all other operations, SimpleDog beats ExactDog. Not a bad trade-off for 2% relative error!

```
Operating System: Linux
CPU Information: AMD Ryzen 9 3900X 12-Core Processor
Number of Available Cores: 24
Available memory: 31.36 GB
Elixir 1.10.3
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 1.17 min

Name                               ips        average  deviation         median         99th %
ExactDog.insert/2            3370.36 K     0.00030 ms  ±4595.86%     0.00025 ms     0.00056 ms
SimpleDog.insert/2           2391.07 K     0.00042 ms  ±7775.41%     0.00031 ms     0.00059 ms
SimpleDog.merge/2              35.43 K      0.0282 ms    ±76.89%      0.0250 ms      0.0402 ms
SimpleDog.quantile/2 50%       17.23 K      0.0580 ms     ±4.50%      0.0573 ms      0.0645 ms
SimpleDog.quantile/2 99%       17.00 K      0.0588 ms     ±7.95%      0.0578 ms      0.0655 ms
SimpleDog.quantile/2 90%       16.98 K      0.0589 ms     ±6.46%      0.0580 ms      0.0653 ms
ExactDog.merge/2                0.60 K        1.66 ms    ±16.64%        1.59 ms        3.07 ms
ExactDog.quantile/2 50%         0.29 K        3.41 ms     ±7.27%        3.32 ms        4.19 ms
ExactDog.quantile/2 99%         0.28 K        3.51 ms     ±6.84%        3.42 ms        4.26 ms
ExactDog.quantile/2 90%         0.28 K        3.51 ms     ±7.10%        3.42 ms        4.28 ms
```

## Installation

The package can be installed by adding `dog_sketch` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dog_sketch, "~> 0.1.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/dog_sketch](https://hexdocs.pm/dog_sketch).
