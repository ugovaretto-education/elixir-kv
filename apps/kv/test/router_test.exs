defmodule KV.RouterTest do
  use ExUnit.Case, async: true
 
  setup_all do
    current = Application.get_env(:kv, :routing_table)
    Application.put_env(:kv, :routing_table, [
      {?a..?m, :"foo@system76.local"},
      {?n..?z, :"bar@metabox.local"}
    ])
    on_exit fn-> Application.put_env(:kv, :routing_table, current) end
  end

  #@tag :distributed
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) ==
             :"foo@system76.local"

    assert KV.Router.route("world", Kernel, :node, []) ==
             :"bar@metabox.local"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end

