defmodule CredoLanguageServerTest do
  use ExUnit.Case, async: true

  import GenLSP.Test

  setup do
    cache = start_supervised!(CredoLanguageServer.Cache)
    server = server(CredoLanguageServer, cache: cache)
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

  test "can initialize the server" do
    assert_result(
      1,
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
    )
  end

  test "publishes diagnostics once the client has initialized", %{client: client, cwd: cwd} do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    assert_notification(
      "window/logMessage",
      %{
        "message" => "[Credo] LSP Initialized!",
        "type" => 4
      },
      500
    )

    for file <- ["foo.ex", "bar.ex"] do
      uri =
        to_string(%URI{
          host: "",
          scheme: "file",
          path: Path.join([cwd, "test/support/fixtures/lib", file])
        })

      assert_notification(
        "textDocument/publishDiagnostics",
        %{"uri" => ^uri, "diagnostics" => [%{"severity" => 4}]},
        500
      )
    end
  end

  test "code actions", %{client: client, cwd: cwd} do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    uri =
      to_string(%URI{
        host: "",
        scheme: "file",
        path: Path.join([cwd, "test/support/fixtures/lib", "foo.ex"])
      })

    assert_notification(
      "textDocument/publishDiagnostics",
      %{"uri" => ^uri, "diagnostics" => [%{"severity" => 4} = diagnostic]},
      500
    )

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

    assert_result(
      2,
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
        }
      ],
      500
    )
  end
end
