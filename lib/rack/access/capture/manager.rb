require 'rack/access/capture/config'

module Rack
  module Access
    module Capture
      class Manager

        attr_accessor :config

        def initialize(app, options = {})
          @app = app
          @config = Rack::Access::Capture::Config.new(options)
          yield @config if block_given?
        end

        def call(env)
          captured_request = @config._watcher.nil? ? {} : @config._watcher.request_capture(env)
          began_at = Time.now.instance_eval { to_i + (usec / 1000000.0) }

          status_code, header, body = @app.call(env)
        ensure
          exec_time = Time.now.instance_eval { to_i + (usec / 1000000.0) } - began_at
          captured_response = @config._watcher.nil? ? {} : @config._watcher.response_capture(env, status_code, header)

          if !@config._collector.nil? && @config._collector.collect?(env)
            access_log = @config._internal_watcher.access_log(env, status_code, header)
            access_log["app_exec_time"] = exec_time
            captured_access_log = merge_logs(captured_request, captured_response, access_log)
            @config._collector.collect(captured_access_log)
          end

          [status_code, header, body]
        end

        private

        def merge_logs(captured_request, captured_response, access_log = {})
          if captured_request && captured_request.is_a?(Hash)
            access_log.merge!(captured_request)
          else
            access_log.merge!(request: captured_request.to_s) unless captured_request.nil?
          end

          if captured_response && captured_response.is_a?(Hash)
            access_log.merge!(captured_response)
          else
            access_log.merge!(response: captured_response.to_s) unless captured_response.nil?
          end

          access_log
        end
      end
    end
  end
end
