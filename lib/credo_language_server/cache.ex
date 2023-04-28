defmodule CredoLanguageServer.Cache do
  @moduledoc """
  Cache for Credo diagnostics.
  """
  require OpenTelemetry.Tracer, as: Tracer

  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> Map.new() end, Keyword.take(opts, [:name]))
  end

  def get(cache) do
    Tracer.with_span :"cache.get", %{} do
      Agent.get(cache, & &1)
    end
  end

  def put(cache, filename, diagnostic) do
    Tracer.with_span :"cache.put", %{} do
      Agent.update(cache, fn cache ->
        Map.update(cache, Path.absname(filename), [diagnostic], fn v ->
          [diagnostic | v]
        end)
      end)
    end
  end

  def clear(cache) do
    Tracer.with_span :"cache.clear", %{} do
      Agent.update(cache, fn cache ->
        for {k, _} <- cache, into: Map.new() do
          {k, []}
        end
      end)
    end
  end
end
