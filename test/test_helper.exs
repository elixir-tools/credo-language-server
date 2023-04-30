{:ok, _} = Application.ensure_all_started(:credo)

GenServer.call(Credo.CLI.Output.Shell, {:supress_output, true})

ExUnit.start()
