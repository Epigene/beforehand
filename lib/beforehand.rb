# frozen_string_literal: true

require "active_record"
require "active_support/all"

require "beforehand/engine"
require "beforehand/active_record_hook"
require "beforehand/cache_key"

module Beforehand
  extend ActiveSupport::Concern
  extend self

  def cache_key(*resources, **context)
    Beforehand::CacheKey.call(*resources, **context)
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, Beforehand::ActiveRecordHook)
end
