require 'rack-access-capture'

module Rack
  class MyWatcher < Rack::Access::Capture::Watcher::BaseAdapter

    def request_capture(env); end

    def response_capture(env, http_status_code, header)
      action = env[:rails_action] || '-'
      { rails_action: action }
    end
  end
end
