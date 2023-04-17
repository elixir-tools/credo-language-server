defmodule CredoLanguageServer do
  @moduledoc """
  LSP implementation for Credo.
  """
  use GenLSP

  alias GenLSP.Enumerations.{CodeActionKind, TextDocumentSyncKind, DiagnosticSeverity}

  alias GenLSP.Notifications.{
    Exit,
    Initialized,
    TextDocumentDidChange,
    TextDocumentDidClose,
    TextDocumentDidOpen,
    TextDocumentDidSave
  }

  alias GenLSP.Requests.{Initialize, Shutdown, TextDocumentCodeAction}

  alias GenLSP.Structures.{
    Diagnostic,
    Position,
    Range,
    CodeActionOptions,
    InitializeParams,
    InitializeResult,
    SaveOptions,
    ServerCapabilities,
    TextDocumentIdentifier,
    TextDocumentSyncOptions
  }

  alias CredoLanguageServer.Cache, as: Diagnostics

  def start_link(args) do
    {args, opts} = Keyword.split(args, [:cache])

    GenLSP.start_link(__MODULE__, args, opts)
  end

  @impl true
  def init(lsp, args) do
    cache = Keyword.fetch!(args, :cache)

    {:ok, assign(lsp, exit_code: 1, cache: cache)}
  end

  @impl true
  def handle_request(%Initialize{params: %InitializeParams{root_uri: root_uri}}, lsp) do
    {:reply,
     %InitializeResult{
       capabilities: %ServerCapabilities{
         text_document_sync: %TextDocumentSyncOptions{
           open_close: true,
           save: %SaveOptions{include_text: true},
           change: TextDocumentSyncKind.full()
         },
         code_action_provider: %CodeActionOptions{code_action_kinds: [CodeActionKind.quick_fix()]}
       },
       server_info: %{name: "Credo"}
     }, assign(lsp, root_uri: root_uri)}
  end

  def handle_request(
        %TextDocumentCodeAction{
          params: %GenLSP.Structures.CodeActionParams{
            context: %GenLSP.Structures.CodeActionContext{diagnostics: diagnostics},
            text_document: %TextDocumentIdentifier{uri: uri}
          }
        },
        lsp
      ) do
    code_actions =
      for %GenLSP.Structures.Diagnostic{} = d <- diagnostics do
        check =
          d.data["check"]
          |> to_string()
          |> String.replace("Elixir.", "")

        position = %GenLSP.Structures.Position{
          line: d.range.start.line,
          character: 0
        }

        %GenLSP.Structures.CodeAction{
          title: "Disable #{check}",
          edit: %GenLSP.Structures.WorkspaceEdit{
            changes: %{
              uri => [
                %GenLSP.Structures.TextEdit{
                  new_text: "# credo:disable-for-next-line #{check}\n",
                  range: %GenLSP.Structures.Range{start: position, end: position}
                }
              ]
            }
          }
        }
      end

    {:reply, code_actions, lsp}
  end

  def handle_request(%Shutdown{}, lsp) do
    {:noreply, assign(lsp, exit_code: 0)}
  end

  @impl true
  def handle_notification(%Initialized{}, lsp) do
    GenLSP.log(lsp, "[Credo] LSP Initialized!")
    refresh(lsp)
    publish(lsp)

    {:noreply, lsp}
  end

  def handle_notification(%TextDocumentDidSave{}, lsp) do
    Task.start_link(fn ->
      Diagnostics.clear(lsp.assigns.cache)
      refresh(lsp)
      publish(lsp)
    end)

    {:noreply, lsp}
  end

  def handle_notification(%TextDocumentDidChange{}, lsp) do
    Task.start_link(fn ->
      Diagnostics.clear(lsp.assigns.cache)
      publish(lsp)
    end)

    {:noreply, lsp}
  end

  def handle_notification(%note{}, lsp)
      when note in [TextDocumentDidOpen, TextDocumentDidClose] do
    {:noreply, lsp}
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
end
