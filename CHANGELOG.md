# CHANGELOG

## [0.1.0](https://github.com/elixir-tools/credo-language-server/compare/v0.1.0-rc.3...v0.1.0) (2023-06-09)


### Miscellaneous Chores

* bump 0.1.0 ([42809b1](https://github.com/elixir-tools/credo-language-server/commit/42809b17d2df388db7565f94009bb4b679f62dae))

## 0.1.0-rc.3

- feat: log runtime errors to the client by @mhanberg in https://github.com/elixir-tools/credo-language-server/pull/48
- fix: wait for runtime to be ready before handling some notifications by @mhanberg in https://github.com/elixir-tools/credo-language-server/pull/49
- feat: replace deps.compile with deps.loadpaths by @mhanberg in https://github.com/elixir-tools/credo-language-server/pull/50
- feat: include more data in diagnostic by @mhanberg in https://github.com/elixir-tools/credo-language-server/pull/52


## 0.1.0-rc.2

- feat!: Changed Readability and Consistency check diagnostics from `hint` to `information` severity.
- fix: build to correct alternate location

  The new runtime will compile artifacts to a new `.elixir-tools` directory in your project root. This should be added to the `.gitignore`

## 0.1.0-rc.1

- Include priv dir when publishing

## 0.1.0-rc.0

- Custom check/plugin compatibility

## v0.0.5

- Correctly shut down and do not leave zombie processes #28

## v0.0.4

- Now reports progress when checking for issues

## v0.0.3

- Code Action: Insert `@moduledoc false` to fix `Credo.Check.Readability.ModuleDoc`

## v0.0.2

- Correctly set Credo's working directory.

## v0.0.1

Initial Release
