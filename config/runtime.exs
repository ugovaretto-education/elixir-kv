import Config
config :kv, :routing_table, [{?a..?z, node()}]

# running the same application on two separate systems
if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"kvapp@system76"},
    {?n..?z, :"kvapp@metabox"}
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
