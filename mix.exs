defmodule Web3MoveEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :web3_move_ex,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      version: "0.6.1",
      description: "cool sdk for Chains using MOVE, such as: aptos, sui, rooch",
      package: package()
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.livemd"],
      maintainers: ["leeduckgo"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/WeLightProject/web3_move_ex"}
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
      {:httpoison, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:jason, ">= 0.0.0"},
      {:json, ">= 0.0.0"},
      {:mox, "~> 1.0", only: :test},
      {:ex_struct_translator, "~> 0.1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:binary, "~> 0.0.5"},
      {:nimble_parsec, "~> 1.2"},
      {:bcs, "~> 0.1.0"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:sui, "~> 0.1.0"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:exbase58, "~> 1.0.2"},
      {:web3_aptos_ex, "~> 1.0.4"}
    ]
  end
end
