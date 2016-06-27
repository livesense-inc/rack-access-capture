require 'rack/access/capture'
require_relative 'app'

use Rack::Access::Capture::Manager, collector: { adapter: :console }
run App
