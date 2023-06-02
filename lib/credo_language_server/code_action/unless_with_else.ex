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

  def refactor(text) do
    {:ok, ast, comments} =
      Code.string_to_quoted_with_comments(text,
        literal_encoder: &{:ok, {:__block__, &2, [&1]}},
        token_metadata: true,
        unescape: false
      )

    IO.inspect(comments)

    ast
    |> IO.inspect()
    |> transform_ast()
    |> Code.quoted_to_algebra(comments: comments)
    # adjust_comment_lines(comments, 1, 5))
    |> Inspect.Algebra.format(:infinity)
    |> IO.iodata_to_binary()
  end

  defp transform_ast({:unless, line, [condition, [block1, block2]]}) do
    {:if, line,
     [condition, [change_block(block2, :do), change_block(block1, :else)]]}
  end

  defp change_block({{:__block__, line, _}, rest}, new) do
    {{:__block__, line, [new]}, rest}
  end

  defp adjust_comment_lines(comments, block_line1, block_line2) do
    comments
    |> Enum.map(&adjust_comment_line(&1, block_line1, block_line2))
  end

  # defp adjust_comment_line(%{previous_eol_count: 0, line: line} = comment) do
  #   Map.put(comment, :line, line + 1)
  # end

  defp adjust_comment_line(%{line: line} = comment, a, b) when line > b do
    diff = b - a
    Map.put(comment, :line, line - diff)
  end

  defp adjust_comment_line(%{line: line} = comment, a, b) when line < b do
    diff = b - a
    Map.put(comment, :line, line + diff)
  end

  defp adjust_comment_line(comment, _a, _b), do: comment
end
