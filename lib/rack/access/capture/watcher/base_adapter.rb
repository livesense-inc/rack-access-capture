module Rack
  module Access
    module Capture
      module Watcher
        class BaseAdapter

          def request_capture(env)
            # this should be overridden by concrete adapters
          end

          def response_capture(env, http_status_code, header)
            # this should be overridden by concrete adapters
          end
        end
      end
    end
  end
end
