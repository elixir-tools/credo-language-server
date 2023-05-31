defmodule CredoLanguageServer.Runtime do
  @moduledoc false
  use GenServer

  require Logger

  @exe :code.priv_dir(:credo_language_server)
       |> Path.join("cmd")
       |> Path.absname()

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  def call(server, mfa), do: GenServer.call(server, {:call, mfa})

  def ready?(server), do: GenServer.call(server, :ready?)

  def init(opts) do
    sname = "credo#{System.system_time()}"
    working_dir = Keyword.fetch!(opts, :working_dir)

    port =
      Port.open(
        {:spawn_executable, @exe},
        [
          :use_stdio,
          :stderr_to_stdout,
          :binary,
          :stream,
          cd: working_dir,
          args: [
            System.find_executable("elixir"),
            "--sname",
            sname,
            "-S",
            "mix",
            "run",
            "--no-halt",
            "--no-start"
          ]
        ]
      )

    me = self()

    Task.start_link(fn ->
      with {:ok, host} <- :inet.gethostname(),
           node <- :"#{sname}@#{host}",
           true <- connect(node, 120) do
        file =
          Path.join(:code.priv_dir(:credo_language_server), "monkey/credo.ex")

        :rpc.call(node, Code, :compile_file, [file])
        send(me, {:node, node})
      else
        _ -> send(me, :cancel)
      end
    end)

    {:ok, %{port: port}}
  end

  def handle_call(:ready?, _from, %{node: _node} = state) do
    {:reply, true, state}
  end

  def handle_call(:ready?, _from, state) do
    {:reply, false, state}
  end

  def handle_call({:call, {m, f, a}}, _from, %{node: node} = state) do
    reply = :rpc.call(node, m, f, a)
    {:reply, reply, state}
  end

  def handle_info({:node, node}, state) do
    {:noreply, Map.put(state, :node, node)}
  end

  def handle_info({port, {:data, data}}, %{port: port} = state) do
    Logger.debug(data)
    {:noreply, state}
  end

  def handle_info({port, other}, %{port: port} = state) do
    Logger.debug(inspect(other))
    {:noreply, state}
  end

  defp connect(_node, 0) do
    raise "failed to connect"
  end

  defp connect(node, attempts) do
    if Node.connect(node) in [false, :ignored] do
      Logger.debug("Couldn't connect to node #{node}, retrying in 1s...")

      Process.sleep(1000)
      connect(node, attempts - 1)
    else
      true
    end
  end
end
