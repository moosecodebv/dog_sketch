defmodule DogSketch.MixProject do
  use Mix.Project

  def project do
    [
      app: :dog_sketch,
      name: "DogSketch",
      package: package(),
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/moosecodebv/dog_sketch",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:propcheck, "~> 1.2", only: :test},
      {:benchee, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.22.2", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: "DDSketch helps you make fast, low-memory, fully mergeable quantile sketches",
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/moosecodebv/dog_sketch"},
      maintainers: ["Derek Kraan"]
    ]
  end
end
