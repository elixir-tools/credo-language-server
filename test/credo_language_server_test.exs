defmodule CredoLanguageServerTest do
  use ExUnit.Case, async: true

  import GenLSP.Test

  setup do
    tvisor = start_supervised!(Task.Supervisor)
    cache = start_supervised!(CredoLanguageServer.Cache)
    server = server(CredoLanguageServer, cache: cache, task_supervisor: tvisor)
    client = client(server)

    cwd = File.cwd!()

    root_path = Path.join(cwd, "test/support/fixtures")

    assert :ok ==
             request(client, %{
               method: "initialize",
               id: 1,
               jsonrpc: "2.0",
               params: %{capabilities: %{}, rootUri: "file://#{root_path}"}
             })

    [server: server, client: client, cwd: cwd]
  end

  test "can start the LSP server", %{server: server} do
    assert alive?(server)
  end

  test "responds correctly to a shutdown request", %{client: client} do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})
    assert :ok == request(client, %{method: "shutdown", id: 2, jsonrpc: "2.0", params: nil})

    assert_result 2, nil, 1000
  end

  test "returns method not found for unimplemented requests", %{client: client} do
    id = System.unique_integer([:positive])
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    assert :ok ==
             request(client, %{
               method: "textDocument/documentSymbol",
               id: id,
               jsonrpc: "2.0",
               params: %{
                 textDocument: %{
                   uri: "file://file/doesnt/matter.ex"
                 }
               }
             })

    assert_notification "window/logMessage",
                        %{
                          "message" => "[Credo] Method Not Found: textDocument/documentSymbol",
                          "type" => 2
                        },
                        500

    assert_error(
      ^id,
      %{
        "code" => -32_601,
        "message" => "Method Not Found: textDocument/documentSymbol"
      },
      500
    )
  end

  test "can initialize the server" do
    assert_result 1,
                  %{
                    "capabilities" => %{
                      "textDocumentSync" => %{
                        "openClose" => true,
                        "save" => %{
                          "includeText" => true
                        },
                        "change" => 1
                      }
                    },
                    "serverInfo" => %{"name" => "Credo"}
                  },
                  500
  end

  test "publishes diagnostics once the client has initialized", %{client: client, cwd: cwd} do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    assert_notification "window/logMessage",
                        %{"message" => "[Credo] LSP Initialized!", "type" => 4},
                        500

    assert_notification "$/progress", %{"value" => %{"kind" => "begin"}}, 500

    for file <- ["foo.ex", "bar.ex"] do
      uri =
        to_string(%URI{
          host: "",
          scheme: "file",
          path: Path.join([cwd, "test/support/fixtures/lib", file])
        })

      assert_notification "textDocument/publishDiagnostics",
                          %{"uri" => ^uri, "diagnostics" => [%{"severity" => 4}]},
                          500
    end

    uri =
      to_string(%URI{
        host: "",
        scheme: "file",
        path: Path.join([cwd, "test/support/fixtures/lib", "code_action.ex"])
      })

    assert_notification "textDocument/publishDiagnostics",
                        %{
                          "uri" => ^uri,
                          "diagnostics" => [%{"severity" => 4}, %{"severity" => 4}]
                        },
                        500

    assert_notification "$/progress",
                        %{
                          "value" => %{"kind" => "end", "message" => "Found 4 issues"}
                        },
                        500
  end

  test "code actions outer module", %{client: client, cwd: cwd} do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    file = %URI{
      host: "",
      scheme: "file",
      path: Path.join([cwd, "test/support/fixtures/lib", "code_action.ex"])
    }

    uri = to_string(file)

    assert_notification "textDocument/publishDiagnostics",
                        %{
                          "uri" => ^uri,
                          "diagnostics" => diagnostics
                        },
                        500

    [
      %{"severity" => 4} = diagnostic,
      %{"severity" => 4}
    ] = Enum.sort(diagnostics)

    assert :ok ==
             notify(client, %{
               method: "textDocument/didOpen",
               jsonrpc: "2.0",
               params: %{
                 textDocument: %{
                   languageId: "elixir",
                   version: 1,
                   uri: uri,
                   text: File.read!(file.path)
                 }
               }
             })

    assert :ok ==
             request(client, %{
               method: "textDocument/codeAction",
               jsonrpc: "2.0",
               id: 2,
               params: %{
                 context: %{diagnostics: [diagnostic]},
                 textDocument: %{uri: uri},
                 range: %{start: %{line: 0, character: 0}, end: %{line: 0, character: 0}}
               }
             })

    assert_result 2,
                  [
                    %{
                      "data" => nil,
                      "edit" => %{
                        "changes" => %{
                          ^uri => [
                            %{
                              "newText" =>
                                "# credo:disable-for-next-line Credo.Check.Readability.ModuleDoc\n",
                              "range" => %{
                                "end" => %{"character" => 0, "line" => 0},
                                "start" => %{"character" => 0, "line" => 0}
                              }
                            }
                          ]
                        }
                      },
                      "title" => "Disable Credo.Check.Readability.ModuleDoc"
                    },
                    %{
                      "data" => nil,
                      "edit" => %{
                        "changes" => %{
                          ^uri => [
                            %{
                              "newText" => "@moduledoc false\n  ",
                              "range" => %{
                                "end" => %{"character" => 2, "line" => 1},
                                "start" => %{"character" => 2, "line" => 1}
                              }
                            }
                          ]
                        }
                      },
                      "title" => "Add \"@moduledoc false\""
                    }
                  ],
                  500
  end

  test "code actions inner module", %{client: client, cwd: cwd} do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    file = %URI{
      host: "",
      scheme: "file",
      path: Path.join([cwd, "test/support/fixtures/lib", "code_action.ex"])
    }

    uri = to_string(file)

    assert_notification "textDocument/publishDiagnostics",
                        %{
                          "uri" => ^uri,
                          "diagnostics" => diagnostics
                        },
                        500

    assert :ok ==
             notify(client, %{
               method: "textDocument/didOpen",
               jsonrpc: "2.0",
               params: %{
                 textDocument: %{
                   languageId: "elixir",
                   version: 1,
                   uri: uri,
                   text: File.read!(file.path)
                 }
               }
             })

    [
      %{"severity" => 4},
      %{"severity" => 4} = diagnostic
    ] = Enum.sort(diagnostics)

    assert :ok ==
             request(client, %{
               method: "textDocument/codeAction",
               jsonrpc: "2.0",
               id: 2,
               params: %{
                 context: %{diagnostics: [diagnostic]},
                 textDocument: %{uri: uri},
                 range: %{start: %{line: 3, character: 2}, end: %{line: 3, character: 2}}
               }
             })

    assert_result 2,
                  [
                    %{
                      "data" => nil,
                      "edit" => %{
                        "changes" => %{
                          ^uri => [
                            %{
                              "newText" =>
                                "# credo:disable-for-next-line Credo.Check.Readability.ModuleDoc\n  ",
                              "range" => %{
                                "end" => %{"character" => 2, "line" => 3},
                                "start" => %{"character" => 2, "line" => 3}
                              }
                            }
                          ]
                        }
                      },
                      "title" => "Disable Credo.Check.Readability.ModuleDoc"
                    },
                    %{
                      "data" => nil,
                      "edit" => %{
                        "changes" => %{
                          ^uri => [
                            %{
                              "newText" => "@moduledoc false\n    ",
                              "range" => %{
                                "end" => %{"character" => 4, "line" => 4},
                                "start" => %{"character" => 4, "line" => 4}
                              }
                            }
                          ]
                        }
                      },
                      "title" => "Add \"@moduledoc false\""
                    }
                  ],
                  500
  end
end
