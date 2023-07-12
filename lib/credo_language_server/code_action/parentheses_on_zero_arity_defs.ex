defmodule CredoLanguageServer.CodeAction.ParenthesesOnZeroArityDefs do
  @moduledoc false

  alias GenLSP.Structures.{
    CodeAction,
    Diagnostic,
    Position,
    Range,
    TextEdit,
    WorkspaceEdit
  }

  require Logger

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

    function_definition = Enum.at(text, start.line)
    new_text = String.replace(function_definition, "()", "")

    %CodeAction{
      title: "Remove parentheses",
      diagnostics: [diagnostic],
      edit: %WorkspaceEdit{
        changes: %{
          uri => [
            %TextEdit{
              new_text: new_text,
              range: %Range{
                start: start,
                end: %Position{
                  start
                  | character: String.length(function_definition)
                }
              }
            }
          ]
        }
      }
    }
  end
end
