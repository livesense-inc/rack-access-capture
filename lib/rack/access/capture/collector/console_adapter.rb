require 'json'
require "rack/access/capture/collector/abstract_adapter"

module Rack
  module Access
    module Capture
      module Collector

        class ConsoleAdapter < AbstractAdapter

          JSON_FORMAT = "JSON".freeze
          LTSV_FORMAT = "LTSV".freeze

          private_constant :JSON_FORMAT, :LTSV_FORMAT

          def initialize(options = {})
            config = options || {}
            @format = config["format"] || 'json'
            @format.upcase!
          end

          def collect?(env)
            true
          end

          def collect(log)
            case @format
            when LTSV_FORMAT
              ltsv(log)
            when JSON_FORMAT
              json(log)
            else
              json(log)
            end
          end

          private

          def json(log)
            $stdout.puts log.to_json
          end

          def ltsv(log)
            $stdout.puts log.map { |k, v| "#{k}:#{v}" }.join("\t") + "\n"
          end
        end
      end
    end
  end
end
