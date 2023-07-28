# CHANGELOG

## [0.3.0](https://github.com/elixir-tools/credo-language-server/compare/v0.2.0...v0.3.0) (2023-07-28)


### Features

* add code action for the ParenthesesOnZeroArityDefs check ([#76](https://github.com/elixir-tools/credo-language-server/issues/76)) ([f846c9d](https://github.com/elixir-tools/credo-language-server/commit/f846c9d34a8d5b64516031df0d3b59122986839c))

## [0.2.0](https://github.com/elixir-tools/credo-language-server/compare/v0.1.3...v0.2.0) (2023-06-27)


### Features

* log version when initialized ([#72](https://github.com/elixir-tools/credo-language-server/issues/72)) ([c4f0cac](https://github.com/elixir-tools/credo-language-server/commit/c4f0caccf5a11c4a26c90b42cf0d9759372b8e0a))


### Bug Fixes

* bump gen_lsp 0.3 ([#69](https://github.com/elixir-tools/credo-language-server/issues/69)) ([0fb8180](https://github.com/elixir-tools/credo-language-server/commit/0fb81804b5741514112c647144be21fe69aec489)), closes [#68](https://github.com/elixir-tools/credo-language-server/issues/68)
* set Runtime.call/2 timeout to :infinity ([#70](https://github.com/elixir-tools/credo-language-server/issues/70)) ([909207b](https://github.com/elixir-tools/credo-language-server/commit/909207b81120232816dc47395feeff947705ef58)), closes [#67](https://github.com/elixir-tools/credo-language-server/issues/67)

## [0.1.3](https://github.com/elixir-tools/credo-language-server/compare/v0.1.2...v0.1.3) (2023-06-23)


### Bug Fixes

* typo in log ([#63](https://github.com/elixir-tools/credo-language-server/issues/63)) ([06f77d7](https://github.com/elixir-tools/credo-language-server/commit/06f77d7334a93b2a7afe7ea41fdaaf9a14f5dda5))

## [0.1.2](https://github.com/elixir-tools/credo-language-server/compare/v0.1.1...v0.1.2) (2023-06-11)


### Bug Fixes

* improve credo-language-server binary ([#61](https://github.com/elixir-tools/credo-language-server/issues/61)) ([218873a](https://github.com/elixir-tools/credo-language-server/commit/218873a79310dee96ade2736b5b8be21402be3d7))

## [0.1.1](https://github.com/elixir-tools/credo-language-server/compare/v0.1.0...v0.1.1) (2023-06-11)


### Bug Fixes

* set -S for shebang in bin/credo-language-server ([#56](https://github.com/elixir-tools/credo-language-server/issues/56)) ([074c895](https://github.com/elixir-tools/credo-language-server/commit/074c895b522f0e3a2b9548ec665e9011746911a2))

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
