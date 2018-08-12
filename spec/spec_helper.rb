ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"
require "factory_bot"
require "pry"
require "database_cleaner"
require "capybara_helper"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.disable_monkey_patching!
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.use_transactional_fixtures = false

  config.before(:suite) do
    FactoryBot.find_definitions

    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |test|
    Beforehand.configure do |c|
      c.anti_dogpile_threshold = 20 # as in 20s
      c.verbose = false
    end

    DatabaseCleaner.strategy = :transaction

    if test.metadata.key?(:wait_time)
      Capybara.default_max_wait_time = test.metadata[:wait_time]
    else
      Capybara.default_max_wait_time = 3 # as in 3 seconds
    end
  end

  config.before(:each, type: :feature) do
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    unless driver_shares_db_connection_with_specs
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
