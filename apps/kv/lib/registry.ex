defmodule KV.Registry do
  use GenServer
  alias :ets, as: Ets

  # Client
  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  def lookup(server, name) do
    case Ets.lookup(server, name) do
      [{^name, bucket_pid}] -> {:ok, bucket_pid}
      [] -> :error
    end
  end

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  # invoke after async call to wait for previous calls to be completed (messages are processed in order)
  def sync(server) do
    GenServer.call(server, :sync)
  end

  # Server
  @impl true
  def init(table) do
    table = Ets.new(table, [:named_table, read_concurrency: true])
    monitored_refs_to_bucket_name = %{}
    {:ok, {table, monitored_refs_to_bucket_name}}
  end

  @impl true
  def handle_call(
        {:create, bucket_name},
        _from,
        {table, monitored_refs_to_bucket_name}
      ) do
    case lookup(table, bucket_name) do
      {:ok, bucket_pid} ->
        {:reply, bucket_pid, {table, monitored_refs_to_bucket_name}}

      :error ->
        {:ok, bucket_pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        pid_ref = Process.monitor(bucket_pid)

        monitored_refs_to_bucket_name =
          Map.put(monitored_refs_to_bucket_name, pid_ref, bucket_name)

        Ets.insert(table, {bucket_name, bucket_pid})

        {:reply, bucket_pid, {table, monitored_refs_to_bucket_name}}
    end
  end

  @impl true
  def handle_call(:sync, _from, state) do
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(
        {:DOWN, monitored_ref, :process, _pid, _reson},
        {table, monitored_refs_to_bucket_name}
      ) do
    {bucket_name, monitored_refs_to_bucket_name} =
      Map.pop(monitored_refs_to_bucket_name, monitored_ref)

    Ets.delete(table, bucket_name)
    {:noreply, {table, monitored_refs_to_bucket_name}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
