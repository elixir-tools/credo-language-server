defmodule CredoLanguageServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_language_server,
      description: "LSP implementation for Credo",
      version: "0.3.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
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

  defp elixirc_paths(:test), do: ["lib", "test/support/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_lsp, "~> 0.3"},
      # {:gen_lsp, path: "../gen_lsp"},
      {:credo, "~> 1.7"},
      {:schematic, "~> 0.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainers: ["Mitchell Hanberg"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/elixir-tools/credo-language-server"
      },
      files: ~w(lib LICENSE mix.exs priv README.md .formatter.exs)
    ]
  end
end
