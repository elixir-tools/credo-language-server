defmodule :_credo_language_server_private_compiler do
  @moduledoc false

  def compile() do
    # keep stdout on this node
    Process.group_leader(self(), Process.whereis(:user))

    Mix.Task.run("deps.compile")
    Mix.Task.run("compile")

    :ok
  rescue
    e -> {:error, e}
  end
end
