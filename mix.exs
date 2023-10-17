defmodule LunaConnect.MixProject do
  use Mix.Project

  def project do
    [
      app: :luna_connect,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls.github": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      dialyzer: [
        plt_file: {:no_warn, ".plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def escript do
    [
      main_module: LunaConnect.CLI,
      name: :luco
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, ">= 1.0.0"},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.10"},
      {:excoveralls, "~> 0.10", only: :test},
      {:jason, "~> 1.4"},
      {:req, "~> 0.4.0"},
      {:yaml_elixir, "~> 2.9"}
    ]
  end

  defp aliases do
    [
      setup: [
        "deps.get",
        "cmd cp -r ./deps/castore/priv/cacerts.pem ./.cacerts"
      ],
      build: ["setup", "escript.build"],
      install: ["build", "escript.install luco"]
    ]
  end
end
