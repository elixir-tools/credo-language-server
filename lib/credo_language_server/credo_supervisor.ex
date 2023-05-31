defmodule CredoLanguageServer.CredoSupervisor do
  @moduledoc false

  use Supervisor

  @env Mix.env()

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    if @env == :test do
      :ignore
    else
      {opts, _} =
        OptionParser.parse!(System.argv(),
          strict: [stdio: :boolean, port: :integer]
        )

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

      children = [
        {CredoLanguageServer.Runtime, name: CredoLanguageServer.Runtime},
        {Task.Supervisor, name: CredoLanguageServer.TaskSupervisor},
        {GenLSP.Buffer, buffer_opts},
        {CredoLanguageServer.Cache, [name: :credo_cache]},
        {CredoLanguageServer,
         cache: :credo_cache,
         task_supervisor: CredoLanguageServer.TaskSupervisor,
         runtime: CredoLanguageServer.Runtime}
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
end
