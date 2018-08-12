source 'https://rubygems.org'

gemspec

Dir.glob(File.join(File.dirname(__FILE__), 'spec', 'dummy', "Gemfile")) do |gemfile|
  eval(IO.read(gemfile), binding)
end
