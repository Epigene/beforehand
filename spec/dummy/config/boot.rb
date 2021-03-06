# Set up gems listed in the Gemfile.
# require "pry"
# binding.pry

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

# puts "Existing gemfile was: #{ENV['BUNDLE_GEMFILE']}"
# puts "Possible dummy gemfile was: #{File.expand_path('../../Gemfile', __FILE__)}"

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

$LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__)

#puts File.expand_path('../../../../lib', __FILE__)
#puts $LOAD_PATH
