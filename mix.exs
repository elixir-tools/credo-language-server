defmodule CredoLanguageServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_language_server,
      description: "LSP implementation for Credo",
      version: "0.0.2",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CredoLanguageServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:gen_lsp, "~> 0.0.10"},
      {:gen_lsp, path: "../gen_lsp"},
      {:credo, "~> 1.0"},
      # {:schematic, path: "../schematic", override: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:opentelemetry_api, "~> 1.2", only: [:dev, :test]},
      {:opentelemetry, "~> 1.2", only: [:dev, :test]},
      {:opentelemetry_exporter, "~> 1.4", only: [:dev, :test]},
      {:opentelemetry_telemetry, "~> 1.0", only: [:dev, :test]},
      {:opentelemetry_process_propagator, "~> 0.2.2", only: [:dev, :test]}
    ]
  end

  defp package() do
    [
      maintainers: ["Mitchell Hanberg"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/elixir-tools/credo-language-server"},
      files: ~w(lib LICENSE mix.exs README.md .formatter.exs)
    ]
  end
end
