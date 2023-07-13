defmodule CredoLanguageServer.Check do
  @moduledoc """
  Data structure for Credo Checks.
  """

  alias Credo.Check.Readability.{
    ModuleDoc,
    ParenthesesOnZeroArityDefs
  }

  @doc """
  Data structure that holds information related to an instance of a check found by Credo.
  """
  defstruct [:check, :diagnostic, :uri, :document]

  def new(opts) do
    opts = Keyword.update!(opts, :check, &String.to_existing_atom/1)
    struct(__MODULE__, opts)
  end

  defimpl CredoLanguageServer.CodeActionable do
    alias CredoLanguageServer.CodeAction

    def fetch(%{check: ModuleDoc} = ca) do
      [
        CodeAction.DisableCheck.new(
          uri: ca.uri,
          diagnostic: ca.diagnostic,
          text: ca.document,
          check: Macro.to_string(ca.check)
        ),
        CodeAction.ModuleDocFalse.new(
          uri: ca.uri,
          diagnostic: ca.diagnostic,
          text: ca.document
        )
      ]
    end

    def fetch(%{check: ParenthesesOnZeroArityDefs} = ca) do
      [
        CodeAction.DisableCheck.new(
          uri: ca.uri,
          diagnostic: ca.diagnostic,
          text: ca.document,
          check: Macro.to_string(ca.check)
        ),
        CodeAction.ParenthesesOnZeroArityDefs.new(
          uri: ca.uri,
          diagnostic: ca.diagnostic,
          text: ca.document
        )
      ]
    end

    def fetch(ca) do
      [
        CodeAction.DisableCheck.new(
          uri: ca.uri,
          diagnostic: ca.diagnostic,
          text: ca.document,
          check: Macro.to_string(ca.check)
        )
      ]
    end
  end
end
