class RequestWatcherAdapter < Rack::Access::Capture::Watcher::BaseAdapter

  def request_capture(env)
    { rails_action: 'index' }
  end

  def response_capture(env, http_status_code, header)
    nil
  end
end
