require 'json'
require "rack/access/capture/collector/abstract_adapter"

module Rack
  module Access
    module Capture
      module Collector

        class ConsoleAdapter < AbstractAdapter

          def initialize(config = {})
          end

          def collect?(env)
            true
          end

          def collect(log)
            $stdout.puts log.to_json
          end
        end
      end
    end
  end
end
