import Config

config :path_finder_service,
  file_name: "cities.csv",
  shard_manager_state: [
    {1, 7, "node-1"},
    {8, 15, "node-2"},
    {16, 23, "node-3"},
    {24, 31, "node-4"}
  ]
