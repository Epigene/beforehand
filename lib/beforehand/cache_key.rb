# frozen_string_literal: true

module Beforehand
  module CacheKey
    # This module generates the context-agnostic cache keys
    extend self

    def call(*resources, **context)
      resource_portion = [resources].flatten.map do |resource|
        resource.cache_key
      end.sort.join("+")

      context_portion = context.sort_by { |k, v| k.to_s }.to_s

      [context_portion, resource_portion].join(":").strip
    end
  end
end
