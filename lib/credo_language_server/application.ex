defmodule CredoLanguageServer.Application do
  @moduledoc false

  use Application

  @env Mix.env()

  @impl true
  def start(_type, _args) do
    children =
      if @env == :test do
        []
      else
        {opts, _} = OptionParser.parse!(System.argv(), strict: [stdio: :boolean, port: :integer])
        {:ok, _} = Application.ensure_all_started(:credo)
        GenServer.call(Credo.CLI.Output.Shell, {:suppress_output, true})

        buffer_opts =
          cond do
            opts[:stdio] ->
              []

            is_integer(opts[:port]) ->
              IO.puts("Starting on port #{opts[:port]}")
              [communication: {GenLSP.Communication.TCP, [port: opts[:port]]}]

            true ->
              raise "Unknown option"
          end

        [
          {GenLSP.Buffer, buffer_opts},
          {CredoLanguageServer.Cache, [name: :credo_cache]},
          {CredoLanguageServer, cache: :credo_cache}
        ]
      end

    opts = [strategy: :one_for_one, name: CredoLanguageServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
