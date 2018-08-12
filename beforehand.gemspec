$:.push File.expand_path("../lib", __FILE__)

require "beforehand/version"

Gem::Specification.new do |s|
  s.name        = "beforehand"
  s.version     = Beforehand::VERSION
  s.authors     = ["Epigene"]
  s.email       = ["augusts.bautra@gmail.com"]
  s.homepage    = "https://github.com/Epigene/beforehand"
  s.summary     = "Fragment cache warming for Rails 4.2+"
  s.description = "beforehand introduces a simple DSL (model callbacks on some steroids) where you define which template(s) to render in the background and pre-cache."
  s.license     = "BSD3"
  s.required_ruby_version = '>= 2.3.7'

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.2.10", "< 6"
  s.add_dependency "backport_new_renderer", "~> 1.0"

  s.add_development_dependency "rails", "~> 4.2.10"

  s.add_development_dependency "rake", "~> 10.5.0"
  s.add_development_dependency "pg", "~> 0.19.0", "< 1"

  s.add_development_dependency "pry", "~> 0.11"
  s.add_development_dependency "rspec-rails", "~> 3.8"
  s.add_development_dependency "factory_bot", "~> 4.10"
  s.add_development_dependency "database_cleaner", "~> 1.7"

  s.add_development_dependency "capybara", "~> 3.5"
  s.add_development_dependency "poltergeist", "~> 1.18"
  s.add_development_dependency "chromedriver-helper", "~> 1.2"

  # #gem "timecop", "~> 0.8.1"
end
