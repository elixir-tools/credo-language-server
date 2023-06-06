# Used by "mix format"
[
  locals_without_parens: [
    assert_result: 2,
    assert_notification: 2,
    assert_result: 3,
    assert_notification: 3,
    notify: 2,
    request: 2
  ],
  line_length: 78,
  import_deps: [:gen_lsp],
  inputs: [
    ".credo.exs",
    "{mix,.formatter}.exs",
    "{config,lib,}/**/*.{ex,exs}",
    "test/credo_language_server_test.exs",
    "test/test_helper.exs",
    "test/credo_language_server/**/*.{ex,exs}",
    "priv/**/*.ex"
  ]
]
