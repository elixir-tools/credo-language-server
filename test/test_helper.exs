{:ok, _pid} =
  Node.start(:"credo_language_server#{System.system_time()}", :shortnames)

Logger.configure(level: :warn)

timeout =
  if System.get_env("CI", "false") == "true" do
    30_000
  else
    10_000
  end

ExUnit.start(assert_receive_timeout: timeout)
