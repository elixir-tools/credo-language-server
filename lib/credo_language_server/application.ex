defmodule CredoLanguageServer.OpentelemetrySchematic do
  require Logger

  @tracer_id __MODULE__

  def setup() do
    :ok =
      :telemetry.attach_many(
        "schematic-handler",
        [
          [:schematic, :unify, :start],
          [:schematic, :unify, :stop]
        ],
        &__MODULE__.process/4,
        nil
      )
  end

  def process([:schematic, :unify, :start], _measurements, metadata, _config) do
    OpentelemetryTelemetry.start_telemetry_span(
      @tracer_id,
      :"schematic.unify.#{metadata.kind} #{metadata.dir}",
      metadata,
      %{kind: :server, attributes: metadata}
    )
  end

  def process([:schematic, :unify, :stop], _measurements, metadata, _config) do
    OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, metadata)
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
  end
end

defmodule CredoLanguageServer.OpentelemetryGenLSP do
  require Logger

  require OpenTelemetry.Tracer, as: Tracer

  @tracer_id __MODULE__

  def setup() do
    :ok =
      :telemetry.attach_many(
        "gen-lsp-handler",
        [
          [:gen_lsp, :loop, :start],
          [:gen_lsp, :loop, :stop],
          [:gen_lsp, :notification, :emit],
          [:gen_lsp, :info, :start],
          [:gen_lsp, :info, :stop],
          [:gen_lsp, :buffer, :read],
          [:gen_lsp, :buffer, :write]
        ],
        &__MODULE__.process/4,
        nil
      )
  end

  def process([:gen_lsp, :buffer, :read], _measurements, metadata, _config) do
    OpenTelemetry.Ctx.clear()

    OpentelemetryTelemetry.start_telemetry_span(@tracer_id, :"gen_lsp.read", metadata, %{
      kind: :server,
      attributes: metadata
    })
  end

  def process([:gen_lsp, :loop, :start], _measurements, metadata, _config) do
    parent_context = OpentelemetryProcessPropagator.fetch_parent_ctx(1, :"$callers")

    if parent_context != :undefined do
      OpenTelemetry.Ctx.attach(parent_context)
    end

    Tracer.update_name(:"gen_lsp.receive.#{metadata.type} #{metadata.method}")
  end

  def process(
        [:gen_lsp, :loop, :stop],
        _measurements,
        %{type: :request, reply: true} = _metadata,
        _config
      ) do
    OpenTelemetry.Ctx.clear()
  end

  def process([:gen_lsp, :loop, :stop], _measurements, metadata, _config) do
    OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, metadata)
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
    OpenTelemetry.Ctx.clear()
  end

  def process([:gen_lsp, :notification, :emit], _measurements, metadata, _config) do
    OpentelemetryTelemetry.start_telemetry_span(
      @tracer_id,
      :"gen_lsp.send.notification #{metadata.method}",
      metadata,
      %{
        kind: :server,
        attributes: metadata
      }
    )
  end

  def process([:gen_lsp, :buffer, :write], _measurements, metadata, _config) do
    parent_context = OpentelemetryProcessPropagator.fetch_parent_ctx(1, :"$callers")

    if parent_context != :undefined do
      OpenTelemetry.Ctx.attach(parent_context)
    end

    OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, metadata)
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
    OpenTelemetry.Ctx.clear()
  end
end

defmodule CredoLanguageServer.Application do
  @moduledoc false

  use Application

  @env Mix.env()

  @impl true
  def start(_type, _args) do
    CredoLanguageServer.OpentelemetrySchematic.setup()
    CredoLanguageServer.OpentelemetryGenLSP.setup()

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
