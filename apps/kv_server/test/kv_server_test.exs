defmodule KVServerTest do
  use ExUnit.Case
  doctest KVServer
  require KV.Registry
  require KV.Bucket

  setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "greets the world" do
    assert KVServer.hello() == :world
  end

  test "spawns buckets from kv_server", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error
    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end
end
