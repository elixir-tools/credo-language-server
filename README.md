# credo-language-server

credo-langauge-server is an LSP implementation for Credo.

## Features

* Project wide diagnostics
* Code Actions

## Editor Support

- Neovim: [elixir-tools.nvim](https://github.com/elixir-tools/elixir-tools.nvim)
- VSCode: [elixir-tools.vscode](https://github.com/elixir-tools/elixir-tools.vscode)

## Installation

The preferred way to use credo-language-server is through one of the supported editor extensions.

If you need to install credo-language-server on it's own, you can download the executable hosted by the GitHub release. The executable is an Elixir script that utilizes `Mix.install/2`.

## Code Actions

### Disable Check

If there is a check that you'd wish to disable, you can trigger the code action on that line to insert a magic comment to disable that check.

---

Built with [gen_lsp](https://github.com/mhanberg/gen_lsp)
