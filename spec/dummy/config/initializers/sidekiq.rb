require 'sidekiq'

config_hash = {url: "redis://127.0.0.1:6379"}

Sidekiq.configure_server do |config|
  config.redis = config_hash
end

Sidekiq.configure_client do |config|
  config.redis = config_hash
end
