defmodule CredoLanguageServer.CodeActions.ModuleDoc do
  def actions(uri, diagnostic) do
    position = %GenLSP.Structures.Position{
      line: diagnostic.range.start.line + 1,
      character: 0
    }

    [
      %GenLSP.Structures.CodeAction{
        title: "Add \"@moduledoc false\"",
        edit: %GenLSP.Structures.WorkspaceEdit{
          changes: %{
            uri => [
              %GenLSP.Structures.TextEdit{
                new_text: "  @moduledoc false\n",
                range: %GenLSP.Structures.Range{start: position, end: position}
              }
            ]
          }
        }
      }
    ]
  end
end
