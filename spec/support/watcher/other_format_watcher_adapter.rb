class OtherFormatWatcherAdapter < Rack::Access::Capture::Watcher::BaseAdapter

  def request_capture(env)
    100
  end

  def response_capture(env, http_status_code, header)
    'response capture'
  end
end
