#require 'capybara/poltergeist'

# if `which phantomjs`.blank?
#   abort("There's no phantomjs in PATH. Google for how to install it!")
# end

# latest gecko (2.1) needs latest selenum gem, problems
# if `which geckodriver`.blank?
#   abort("No 'geckodriver' in PATH. It's needed for selenium")
# end


# makes outside request for setup
Chromedriver.set_version "2.41" # as of 2018-08-12

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(--window-size=1500,900) }
  )

  Capybara::Selenium::Driver.new(app, {
    port: 52674 + ENV['TEST_ENV_NUMBER'].to_i,
    browser: :chrome,
    desired_capabilities: capabilities
  })
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu --window-size=1920,960 --blink-settings=imagesEnabled=false) }
  )

  Capybara::Selenium::Driver.new(app, {
    port: 53674 + ENV['TEST_ENV_NUMBER'].to_i,
    browser: :chrome,
    desired_capabilities: capabilities
  })
end

require "rack/handler/puma"

Capybara.register_server :silent_puma do |app, port, host|
  Rack::Handler::Puma.run(app, Port: port, Threads: "0:1", Silent: true)
end

# Prefer :silent_puma, but there's a bug https://github.com/rspec/rspec-rails/issues/1908
#Capybara.server = :webrick # :silent_puma, # :puma
Capybara.server = :silent_puma # :silent_puma, # :puma

Capybara.server_port = 3000
Capybara.default_driver = :rack_test

#== Available JS drivers ==
# :headless_chrome - OK speed, full functionality. 0.5% fail rate
# :chrome - Shows actual browser window, excellent for debugging

Capybara.javascript_driver = :headless_chrome
