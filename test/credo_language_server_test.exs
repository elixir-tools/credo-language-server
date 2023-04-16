defmodule CredoLanguageServerTest do
  use ExUnit.Case
  doctest CredoLanguageServer

  test "greets the world" do
    assert CredoLanguageServer.hello() == :world
  end
end
