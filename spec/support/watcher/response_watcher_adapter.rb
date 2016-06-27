class ResponseWatcherAdapter < Rack::Access::Capture::Watcher::BaseAdapter

  def request_capture(env)
    nil
  end

  def response_capture(env, http_status_code, header)
    { response_data: 'response data' }
  end
end
