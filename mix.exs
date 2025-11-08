defmodule FrenchNumbers.MixProject do
  use Mix.Project

  def project do
    [
      app: :french_numbers,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: "Convert numbers to their French word representations.",
      source_url: "https://github.com/evenfurther/french-numbers-ex",
      homepage_url: "https://rfc1149.net/devel/french-numbers-ex.html",
      deps: deps(),
    ]
  end

  defp package do
    [
      files: ~w(lib README.md test mix.exs),
      licenses: ["Apache-2.0", "MIT"],
      links: %{"GitHub" => "https://github.com/evenfurther/french-numbers-ex"},
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
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
    ]
  end
end
