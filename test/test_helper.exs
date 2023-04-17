{:ok, _} = Application.ensure_all_started(:credo)
GenServer.call(Credo.CLI.Output.Shell, {:suppress_output, true})

ExUnit.start()
