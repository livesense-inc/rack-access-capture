class RequestAndResponseWatcherAdapter < Rack::Access::Capture::Watcher::BaseAdapter

  def request_capture(env)
    { rails_action: 'destroy' }
  end

  def response_capture(env, http_status_code, header)
    { response_data: 'response data' }
  end
end
