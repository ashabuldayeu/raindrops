import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rain_drops, RainDropsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "oP5eciwoMO6UYuhnmeTfsQX1euXZz2zsZCYzNSCUViUlKi+qBQWjdm6q1H7t+fFn",
  server: false

# In test we don't send emails
config :rain_drops, RainDrops.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
