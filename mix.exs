defmodule CredoLanguageServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_language_server,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
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
end
