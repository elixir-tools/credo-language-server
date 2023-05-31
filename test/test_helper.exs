{:ok, _} = Application.ensure_all_started(:credo)
{:ok, _pid} = Node.start(:credo_language_server, :shortnames)

Logger.configure(level: :warn)

ExUnit.start()
