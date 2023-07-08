defmodule CredoLanguageServer.CodeAction.ParenthesesOnZeroArityDefsTest do
  use ExUnit.Case, async: true

  alias CredoLanguageServer.CodeAction.ParenthesesOnZeroArityDefs

  alias GenLSP.Structures.{
    CodeAction,
    CodeDescription,
    Diagnostic,
    Position,
    Range,
    TextEdit,
    WorkspaceEdit
  }

  describe "new" do
    test "provides a code action that removes unnecessary parentheses" do
      diagnostic = %Diagnostic{
        data: %{
          "check" =>
            "Elixir.Credo.Check.Readability.ParenthesesOnZeroArityDefs",
          "file" => "foo.ex"
        },
        related_information: nil,
        tags: nil,
        message:
          "Do not use parentheses when defining a function which has no arguments.",
        source: "credo",
        code_description: %CodeDescription{
          href:
            "https://hexdocs.pm/credo/Credo.Check.Readability.ParenthesesOnZeroArityDefs.html"
        },
        code: "Credo.Check.Readability.ParenthesesOnZeroArityDefs",
        severity: 3,
        range: %Range{
          start: %Position{character: 0, line: 1},
          end: %Position{character: 1, line: 1}
        }
      }

      text = [
        "defmodule Test do",
        "  def foo() do",
        "    :bar",
        "  end",
        "end",
        ""
      ]

      assert %CodeAction{
               title: "Remove parentheses",
               diagnostics: [^diagnostic],
               edit: %WorkspaceEdit{
                 changes: %{
                   "uri" => [
                     %TextEdit{
                       new_text: "  def foo do",
                       range: %Range{
                         start: %Position{character: 0, line: 1},
                         end: %Position{character: 14, line: 1}
                       }
                     }
                   ]
                 }
               }
             } =
               ParenthesesOnZeroArityDefs.new(%{
                 diagnostic: diagnostic,
                 text: text,
                 uri: "uri"
               })
    end
  end
end
