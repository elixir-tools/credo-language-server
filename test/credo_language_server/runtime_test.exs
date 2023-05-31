defmodule CredoLanguageServer.RuntimeTest do
  use ExUnit.Case, async: true

  alias CredoLanguageServer.Runtime

  test "can run code on the node" do
    pid =
      start_supervised!(
        {Runtime, working_dir: Path.absname("test/support/project")}
      )

    assert wait_for_ready(pid)
  end

  defp wait_for_ready(pid) do
    with false <- Runtime.ready?(pid) do
      Process.sleep(100)
      wait_for_ready(pid)
    end
  end
end
