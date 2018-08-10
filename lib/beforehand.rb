# frozen_string_literal: true

require "active_record"
require "beforehand/engine"

require "beforehand/active_record_hook"


module Beforehand
  extend ActiveSupport::Concern
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, Beforehand::ActiveRecordHook)
end
