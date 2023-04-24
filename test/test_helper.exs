{:ok, _} = Application.ensure_all_started(:credo)

case Application.spec(:credo, :vsn) do
  '1.5.6' ->
    GenServer.call(Credo.CLI.Output.Shell, {:supress_output, true})

  _ ->
    GenServer.call(Credo.CLI.Output.Shell, {:suppress_output, true})
end

ExUnit.start()
