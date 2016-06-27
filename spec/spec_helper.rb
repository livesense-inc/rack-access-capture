require 'rack'
require 'yaml'
require 'rack-access-capture'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
