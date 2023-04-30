defmodule CredoLanguageServer.CodeAction.DisableCheck do
  @moduledoc false

  alias GenLSP.Structures.{
    CodeAction,
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
      text: Schematic.list(Schematic.str()),
      check: Schematic.str()
    })
  end

  def new(opts) do
    {:ok,
     %{
       diagnostic: diagnostic,
       uri: uri,
       text: text,
       check: check
     }} = Schematic.unify(opts(), Map.new(opts))

    start = diagnostic.range.start

    indent =
      text
      |> Enum.at(start.line)
      |> (&Regex.run(~r/^(\s*).*/, &1)).()
      |> List.last()

    position = %Position{
      line: start.line,
      character: String.length(indent)
    }

    %CodeAction{
      title: "Disable #{check}",
      edit: %WorkspaceEdit{
        changes: %{
          uri => [
            %TextEdit{
              new_text: "# credo:disable-for-next-line #{check}\n#{indent}",
              range: %Range{start: position, end: position}
            }
          ]
        }
      }
    }
  end
end
