# credo-language-server

[![Discord](https://img.shields.io/badge/Discord-5865F3?style=flat&logo=discord&logoColor=white&link=https://discord.gg/nNDMwTJ8)](https://discord.gg/6XdGnxVA2A)
[![Hex.pm](https://img.shields.io/hexpm/v/credo_language_server)](https://hex.pm/packages/credo_language_server)
![GitHub Discussions](https://img.shields.io/github/discussions/elixir-tools/discussions)

credo-language-server is an LSP implementation for Credo.

## Features

* Project wide diagnostics
* Code Actions

## Editor Support

<ul>
<li>Neovim: <a href="https://github.com/elixir-tools/elixir-tools.nvim">elixir-tools.nvim</a></li>
<li>VSCode: <a href="https://github.com/elixir-tools/elixir-tools.vscode">elixir-tools.vscode</a></li>

<li>
<details>
<summary>Helix</summary>

Here is an example configuration for `languages.toml`

```toml
[[language]]
name = "elixir"
scope = "source.elixir"
injection-regex = "elixir"
file-types = ["ex", "exs"]
roots = ["mix.exs"]
auto-format = false
diagnostic-severity = "Hint"
comment-token = "#"
indent = {tab-width = 2, unit = " "}
language-servers = ["elixir-ls", "credo"]

[language-server.elixir-ls]
command = "elixir-ls"
config = { elixirLS.dialyzerEnabled = true }

[language-server.credo]
command = "/path/to/executable/credo-language-server"
args = ["--stdio=true", "--port=999"]
```

</details>
</li>
</ul>

## Installation

The preferred way to use credo-language-server is through one of the supported editor extensions.

If you need to install credo-language-server on it's own, you can download the executable hosted by the GitHub release. The executable is an Elixir script that utilizes `Mix.install/2`.

### Note

Credo Language Server creates an `.elixir-tools` hidden directory in your project.

This should be added to your project's `.gitignore`.

## Code Actions

### DisableCheck

Check: all

If there is a check that you'd wish to disable, you can trigger the code action on that line to insert a magic comment to disable that check.

### ModuleDocFalse

Check: `Credo.Check.Readability.ModuleDoc`

Inject a `@moduledoc false` snippet into the module.

---

Built with [gen_lsp](https://github.com/mhanberg/gen_lsp)
