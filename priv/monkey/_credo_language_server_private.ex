defmodule :_credo_language_server_private do
  @moduledoc false

  def issues(dir) do
    ["--strict", "--all", "--working-dir", dir]
    |> Credo.run()
    |> Credo.Execution.get_issues()
  end

  def compile() do
    # keep stdout on this node
    Process.group_leader(self(), Process.whereis(:user))

    Mix.Task.run("deps.compile")
    Mix.Task.run("compile")

    :ok
  rescue
    _ -> :error
  end
end
