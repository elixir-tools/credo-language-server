defmodule CredoLanguageServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_language_server,
      description: "LSP implementation for Credo",
      version: "0.0.5",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      lockfile: System.get_env("CREDO_LOCKFILE", "mix.lock")
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
      {:gen_lsp, "~> 0.0.12"},
      # {:gen_lsp, path: "../gen_lsp"},
      {:credo, "~> 1.0"},
      {:schematic, "~> 0.0.11"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
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
