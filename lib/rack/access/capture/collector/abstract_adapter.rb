module Rack
  module Access
    module Capture
      module Collector

        class AbstractAdapter

          def collect?(env)
            false
          end

          # This is meant to be implemented by the adapters that support access log collect.
          def collect
            # this should be overridden by concrete adapters
          end
        end
      end
    end
  end
end
