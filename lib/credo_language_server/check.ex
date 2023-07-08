defmodule CredoLanguageServer.Check do
  @moduledoc """
  Data structure for Credo Checks.
  """

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

    def fetch(
          %{
            check: Credo.Check.Readability.ModuleDoc,
            diagnostic: diagnostic,
            uri: uri,
            document: document
          } = opts
        ) do
      [
        disable_check(opts),
        CodeAction.ModuleDocFalse.new(
          uri: uri,
          diagnostic: diagnostic,
          text: document
        )
      ]
    end

    def fetch(
          %{
            check: Credo.Check.Readability.ParenthesesOnZeroArityDefs,
            diagnostic: diagnostic,
            uri: uri,
            document: document
          } = opts
        ) do
      [
        disable_check(opts),
        CodeAction.ParenthesesOnZeroArityDefs.new(
          uri: uri,
          diagnostic: diagnostic,
          text: document
        )
      ]
    end

    def fetch(opts) do
      [disable_check(opts)]
    end

    defp disable_check(%{
           check: check,
           diagnostic: diagnostic,
           uri: uri,
           document: document
         }) do
      CodeAction.DisableCheck.new(
        uri: uri,
        diagnostic: diagnostic,
        text: document,
        check: Macro.to_string(check)
      )
    end
  end
end
