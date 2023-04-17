defmodule CredoLanguageServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_language_server,
      description: "LSP implementation for Credo",
      version: "0.0.1",
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
      {:gen_lsp, "~> 0.0.10"},
      # {:gen_lsp, path: "../gen_lsp"},
      {:credo, "~> 1.0"}
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
