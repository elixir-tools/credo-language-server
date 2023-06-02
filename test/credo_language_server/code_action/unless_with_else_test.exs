defmodule CredoLanguageServer.CodeAction.UnlessWithElseTest do
  use ExUnit.Case, async: true

  alias CredoLanguageServer.CodeAction.UnlessWithElse

  describe "refactor" do
    test "replaces unless with if and swaps code blocks" do
      source = """
      unless allowed? do
        raise "Not allowed!"
      else
        proceed_as_planned()
      end
      """

      expected_result =
        """
        if allowed? do
          proceed_as_planned()
        else
          raise "Not allowed!"
        end
        """
        |> String.trim_trailing()

      result = UnlessWithElse.refactor(source)

      assert result == expected_result
    end

    test "preserves comments" do
      source = """
      unless allowed? do
        # one
        raise "Not allowed!" # two
        # three
      else
        # four
        proceed_as_planned() # five
        # six
      end
      """

      expected_result =
        """
        if allowed? do
          # four
          proceed_as_planned() # five
          # six
        else
          # one
          raise "Not allowed!" # two
          # three
        end
        """
        |> String.trim_trailing()

      result = UnlessWithElse.refactor(source)

      assert result == expected_result
    end
  end
end
