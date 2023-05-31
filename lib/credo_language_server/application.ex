defmodule CredoLanguageServer.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: CredoLanguageServer.Supervisor]

    Supervisor.start_link([CredoLanguageServer.CredoSupervisor], opts)
  end
end
