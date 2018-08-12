# frozen_string_literal: true

require "active_record"
require "active_support/all"

require "beforehand/engine"
require "beforehand/active_record_hook"
require "beforehand/cache_key"

module Beforehand
  extend ActiveSupport::Concern
  extend self
  mattr_accessor :on_app_init_list

  class << self
    attr_accessor :configuration
  end

  def enqueue
    # Only trigger post-initialization caching if explicitly told so.
    return unless ENV["CACHE_BEFOREHAND"]

    "TODO"
  end

  def cache_key(*resources, **context)
    Beforehand::CacheKey.call(*resources, **context)
  end

  def configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :verbose, :anti_dogpile_threshold, :strict_beforehand_options

    def initialize
      @verbose = false
      @anti_dogpile_threshold = 20
      @strict_beforehand_options = true
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, Beforehand::ActiveRecordHook)
end
