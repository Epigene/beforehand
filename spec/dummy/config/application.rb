require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true

    config.after_initialize do
      Rails.log("--> Clearing Rails cache after initialization")
      Rails.cache.clear
    end
  end
end

