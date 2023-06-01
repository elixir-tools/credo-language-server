defmodule CredoLanguageServer.CodeAction.UnlessWithElse do
  @moduledoc false

  alias GenLSP.Structures.{
    CodeAction,
    WorkspaceEdit
  }

  def new(opts) do
    %CodeAction{
      title: "Refactor to use if",
      diagnostics: [opts.diagnostic],
      edit: %WorkspaceEdit{}
    }
  end
end
