config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"foo@system76.local"},
    {?n..?z, :"bar@metabox.local"}
  ]
end
