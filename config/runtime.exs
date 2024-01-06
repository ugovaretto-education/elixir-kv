import Config
config :kv, :routing_table, [{?a..?z, node()}]

# running the same application on two separate systems
if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"kvapp@system76.local"},
    {?n..?z, :"kvapp@metabox.local"}
  ]
end

# running two separate applications, requires setting
# two releases, one per app.
# When running on the same node the bar application should not contain the server
# since only a single frontend listening on a port is needed, or configure the port
# in runtime.exs
# if config_env() == :prod do
#   config :kv, :routing_table, [
#     {?a..?m, :"kvapp@system76.local"},
#     {?n..?z, :"kvapp@metabox.local"}
#   ]
# end

# Example release configuration with single entry point: two DB servers and one
# TCP server as entry point
# releases: [
#   foo: [
#     version: "0.0.1",
#     applications: [kv_server: :permanent, kv: :permanent],
#     cookie: "weknoweachother"
#   ],
#   bar: [
#     version: "0.0.1",
#     applications: [kv: :permanent],
#     cookie: "weknoweachother"
#   ]
# ]
