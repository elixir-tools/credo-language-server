defmodule CredoLanguageServer.RuntimeTest do
  use ExUnit.Case, async: true

  require Logger

  import ExUnit.CaptureLog

  alias CredoLanguageServer.Runtime

  setup do
    {:ok, logger} =
      Task.start_link(fn ->
        recv = fn recv ->
          receive do
            {:log, msg} ->
              Logger.debug(msg)
          end

          recv.(recv)
        end

        recv.(recv)
      end)

    [logger: logger]
  end

  test "can run code on the node", %{logger: logger} do
    capture_log(fn ->
      pid =
        start_supervised!(
          {Runtime,
           working_dir: Path.absname("test/support/project"), parent: logger}
        )

      assert wait_for_ready(pid)
    end) =~ "Connected to node"
  end

  defp wait_for_ready(pid) do
    with false <- Runtime.ready?(pid) do
      Process.sleep(100)
      wait_for_ready(pid)
    end
  end
end
