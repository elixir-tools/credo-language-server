{:ok, _pid} =
  Node.start(:"credo_language_server#{System.system_time()}", :shortnames)

Logger.configure(level: :warn)

ExUnit.start(assert_receive_timeout: 10_000)
