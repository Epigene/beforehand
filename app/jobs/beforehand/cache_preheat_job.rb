# frozen_string_literal: true

module Beforehand
  CachePreheatJob =
    if defined?(ApplicationJob)
      Class.new(ApplicationJob)
    else
      Class.new(ActiveJob::Base)
    end

  CachePreheatJob.class_eval do
    def perform(klass, id, method, *args)
      "TODO"
    end
  end
end
