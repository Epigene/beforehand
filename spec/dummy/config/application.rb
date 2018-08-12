require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true

    config.cache_store = :redis_store, "redis://127.0.0.1:6380"
    config.active_job.queue_adapter = :sidekiq

    config.after_initialize do
      Rails.logger.info("--> Clearing Rails cache after initialization")
      Rails.cache.clear
    end
  end
end

