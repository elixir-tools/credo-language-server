defmodule CredoLanguageServer do
  @moduledoc """
  LSP implementation for Credo.
  """
  use GenLSP

  alias GenLSP.ErrorResponse

  alias GenLSP.Enumerations.{
    CodeActionKind,
    DiagnosticSeverity,
    ErrorCodes,
    TextDocumentSyncKind
  }

  alias GenLSP.Notifications.{
    Exit,
    Initialized,
    TextDocumentDidChange,
    TextDocumentDidOpen,
    TextDocumentDidSave
  }

  alias GenLSP.Requests.{Initialize, Shutdown, TextDocumentCodeAction}

  alias GenLSP.Structures.{
    CodeActionContext,
    CodeActionOptions,
    CodeActionParams,
    Diagnostic,
    DidOpenTextDocumentParams,
    InitializeParams,
    InitializeResult,
    Position,
    Range,
    SaveOptions,
    ServerCapabilities,
    TextDocumentIdentifier,
    TextDocumentItem,
    TextDocumentSyncOptions,
    WorkDoneProgressBegin,
    WorkDoneProgressEnd
  }

  alias CredoLanguageServer.Cache, as: Diagnostics

  def start_link(args) do
    {args, opts} = Keyword.split(args, [:cache])

    GenLSP.start_link(__MODULE__, args, opts)
  end

  @impl true
  def init(lsp, args) do
    cache = Keyword.fetch!(args, :cache)

    {:ok, assign(lsp, exit_code: 1, cache: cache, documents: %{})}
  end

  @impl true
  def handle_request(%Initialize{params: %InitializeParams{root_uri: root_uri}}, lsp) do
    token = generate_token(8)

    GenLSP.notify(lsp, %GenLSP.Notifications.DollarProgress{
      params: %GenLSP.Structures.ProgressParams{
        token: token,
        value: %WorkDoneProgressBegin{
          kind: "begin",
          title: "Credo Language Server"
        }
      }
    })

    {:reply,
     %InitializeResult{
       capabilities: %ServerCapabilities{
         text_document_sync: %TextDocumentSyncOptions{
           open_close: true,
           save: %SaveOptions{include_text: true},
           change: TextDocumentSyncKind.full()
         },
         code_action_provider: %CodeActionOptions{
           code_action_kinds: [CodeActionKind.quick_fix()]
         }
       },
       server_info: %{name: "Credo"}
     }, assign(lsp, root_uri: root_uri, init_token: token)}
  end

  def handle_request(
        %TextDocumentCodeAction{
          params: %CodeActionParams{
            context: %CodeActionContext{diagnostics: diagnostics},
            text_document: %TextDocumentIdentifier{uri: uri}
          }
        },
        lsp
      ) do
    code_actions =
      for %Diagnostic{data: %{"check" => check}} = diagnostic <- diagnostics,
          check =
            CredoLanguageServer.Check.new(
              check: check,
              diagnostic: diagnostic,
              uri: uri,
              document: lsp.assigns.documents[uri]
            ),
          action <- CredoLanguageServer.CodeActionable.fetch(check) do
        action
      end

    {:reply, code_actions, lsp}
  end

  def handle_request(%Shutdown{}, lsp) do
    {:noreply, assign(lsp, exit_code: 0)}
  end

  def handle_request(%{method: method}, lsp) do
    GenLSP.warning(lsp, "[Credo] Method Not Found: #{method}")

    {:reply,
     %ErrorResponse{
       code: ErrorCodes.method_not_found(),
       message: "Method Not Found: #{method}"
     }, lsp}
  end

  @impl true
  def handle_notification(%Initialized{}, lsp) do
    GenLSP.log(lsp, "[Credo] LSP Initialized!")

    GenLSP.notify(lsp, %GenLSP.Notifications.DollarProgress{
      params: %GenLSP.Structures.ProgressParams{
        token: lsp.assigns.init_token,
        value: %WorkDoneProgressEnd{
          kind: "end"
        }
      }
    })

    refresh(lsp)
    publish(lsp)

    {:noreply, lsp}
  end

  def handle_notification(
        %TextDocumentDidSave{
          params: %GenLSP.Structures.DidSaveTextDocumentParams{
            text: text,
            text_document: %{uri: uri}
          }
        },
        lsp
      ) do
    Task.start_link(fn ->
      Diagnostics.clear(lsp.assigns.cache)
      refresh(lsp)
      publish(lsp)
    end)

    {:noreply, put_in(lsp.assigns.documents[uri], String.split(text, "\n"))}
  end

  def handle_notification(%TextDocumentDidChange{}, lsp) do
    Task.start_link(fn ->
      Diagnostics.clear(lsp.assigns.cache)
      publish(lsp)
    end)

    {:noreply, lsp}
  end

  def handle_notification(
        %TextDocumentDidOpen{
          params: %DidOpenTextDocumentParams{
            text_document: %TextDocumentItem{text: text, uri: uri}
          }
        },
        lsp
      ) do
    {:noreply, put_in(lsp.assigns.documents[uri], String.split(text, "\n"))}
  end

  def handle_notification(%Exit{}, lsp) do
    System.halt(lsp.assigns.exit_code)

    {:noreply, lsp}
  end

  def handle_notification(_thing, lsp) do
    {:noreply, lsp}
  end

  defp refresh(lsp) do
    dir = URI.parse(lsp.assigns.root_uri).path

    issues =
      ["--strict", "--all", "--working-dir", dir]
      |> Credo.run()
      |> Credo.Execution.get_issues()

    GenLSP.info(lsp, "[Credo] Found #{Enum.count(issues)} issues")

    for issue <- issues do
      diagnostic = %Diagnostic{
        range: %Range{
          start: %Position{line: issue.line_no - 1, character: (issue.column || 1) - 1},
          end: %Position{line: issue.line_no - 1, character: issue.column || 1}
        },
        severity: category_to_severity(issue.category),
        data: %{check: issue.check, file: issue.filename},
        message: """
        #{issue.message}

        ## Explanation

        #{issue.check.explanations()[:check]}
        """
      }

      Diagnostics.put(lsp.assigns.cache, Path.absname(issue.filename), diagnostic)
    end
  end

  defp publish(lsp) do
    for {file, diagnostics} <- Diagnostics.get(lsp.assigns.cache) do
      GenLSP.notify(lsp, %GenLSP.Notifications.TextDocumentPublishDiagnostics{
        params: %GenLSP.Structures.PublishDiagnosticsParams{
          uri: "file://#{file}",
          diagnostics: diagnostics
        }
      })
    end
  end

  defp category_to_severity(:refactor), do: DiagnosticSeverity.error()
  defp category_to_severity(:warning), do: DiagnosticSeverity.warning()
  defp category_to_severity(:design), do: DiagnosticSeverity.information()
  defp category_to_severity(:consistency), do: DiagnosticSeverity.hint()
  defp category_to_severity(:readability), do: DiagnosticSeverity.hint()

  defp generate_token(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
