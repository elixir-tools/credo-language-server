defmodule CredoLanguageServer.CodeAction.ModuleDocFalse do
  @moduledoc false

  alias GenLSP.Structures.{
    CodeAction,
    Diagnostic,
    Position,
    Range,
    TextEdit,
    WorkspaceEdit
  }

  defp opts do
    Schematic.map(%{
      # TODO: schematic needs a way to define a struct
      diagnostic: Schematic.any(),
      uri: Schematic.str(),
      text: Schematic.list(Schematic.str())
    })
  end

  def new(opts) do
    {:ok,
     %{
       diagnostic: %Diagnostic{range: %{start: start}} = diagnostic,
       uri: uri,
       text: text
     }} = Schematic.unify(opts(), Map.new(opts))

    indent =
      text
      |> Enum.at(start.line)
      |> then(&Regex.run(~r/^(\s*).*/, &1))
      |> List.last()
      |> Kernel.<>("  ")

    position = %Position{
      line: start.line + 1,
      character: String.length(indent)
    }

    %CodeAction{
      title: "Add \"@moduledoc false\"",
      diagnostics: [diagnostic],
      edit: %WorkspaceEdit{
        changes: %{
          uri => [
            %TextEdit{
              new_text: "@moduledoc false\n#{indent}",
              range: %Range{start: position, end: position}
            }
          ]
        }
      }
    }
  end
end
