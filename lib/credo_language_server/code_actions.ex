defmodule CredoLanguageServer.CodeActions do
  def for_check(check) do
    actions =
      case check do
        "Credo.Check.Readability.ModuleDoc" ->
          [__MODULE__.ModuleDocFalse]

        _ ->
          []
      end

    [__MODULE__.DisableCheck] ++ actions
  end

  defmodule ModuleDocFalse do
    def actions(uri, diagnostic) do
      start = diagnostic.range.start

      position = %GenLSP.Structures.Position{
        line: start.line + 1,
        character: 0
      }

      pad = String.duplicate(" ", start.character - 8)

      [
        %GenLSP.Structures.CodeAction{
          title: "Add \"@moduledoc false\"",
          edit: %GenLSP.Structures.WorkspaceEdit{
            changes: %{
              uri => [
                %GenLSP.Structures.TextEdit{
                  new_text: "#{pad}@moduledoc false\n",
                  range: %GenLSP.Structures.Range{start: position, end: position}
                }
              ]
            }
          }
        }
      ]
    end
  end

  defmodule DisableCheck do
    def actions(uri, diagnostic) do
      check =
        diagnostic.data["check"]
        |> to_string()
        |> String.replace("Elixir.", "")

      position = %GenLSP.Structures.Position{
        line: diagnostic.range.start.line,
        character: 0
      }

      [
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
      ]
    end
  end
end
