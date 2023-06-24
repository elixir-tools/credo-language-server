# credo-language-server

[![Discord](https://img.shields.io/badge/Discord-5865F3?style=flat&logo=discord&logoColor=white&link=https://discord.gg/nNDMwTJ8)](https://discord.gg/6XdGnxVA2A)
[![Hex.pm](https://img.shields.io/hexpm/v/credo_language_server)](https://hex.pm/packages/credo_language_server)
[![GitHub Discussions](https://img.shields.io/github/discussions/elixir-tools/discussions)](https://github.com/orgs/elixir-tools/discussions)

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
<summary>Emacs</summary>

#### Using lsp-mode:

credo-language-server is included with [lsp-mode](https://github.com/emacs-lsp/lsp-mode) and can be installed by running `M-x lsp-install-server credo-language-server`.

You might want to set the lsp-credo-version to the latest release:

```elisp
(custom-set-variables '(lsp-credo-version "0.1.3"))
```

or by running `M-x customize-group lsp-credo` and updating the version.

Visit [lsp-mode](https://github.com/emacs-lsp/lsp-mode) for detailed
installation instructions.

#### Using eglot:

```elisp
(require 'eglot)

(add-to-list 'exec-path "path/to/credo-language-server/bin")

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((elixir-ts-mode heex-ts-mode elixir-mode) .
                 ("credo-language-server" "--stdio=true"))))

(add-hook 'elixir-mode-hook 'eglot-ensure)
(add-hook 'elixir-ts-mode-hook 'eglot-ensure)
(add-hook 'heex-ts-mode-hook 'eglot-ensure)
```

Eglot only allows one server per mode, but it is possible to
configure eglot alternatives to prompt for a specific language server.

```elisp
(require 'eglot)

(setq exec-path
      (append exec-path
              '("path/to/credo-language-server/bin"
                "path/to/elixir-ls/bin")))

(add-to-list
 'eglot-server-programs
 `((elixir-mode elixir-ts-mode heex-ts-mode) .
   ,(eglot-alternatives
     `(,(if (and (fboundp 'w32-shell-dos-semantics)
                 (w32-shell-dos-semantics))
            '("language_server.bat")
          '("language_server.sh"))
       ("credo-language-server" "--stdio=true")))))
```

</details>
</li>
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
