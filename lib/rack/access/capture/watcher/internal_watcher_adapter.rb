require 'woothee'
require 'rack/access/capture/watcher/base_adapter'

module Rack
  module Access
    module Capture
      module Watcher
        class InternalWatcherAdapter < BaseAdapter

          attr_reader :filter_params

          def initialize(config = {})
            params = config.is_a?(Hash) && config.key?("params") ? config["params"] : []
            @filter_params = initialize_filter_params(params)
          end

          def access_log(env, status_code, header)
            request = Rack::Request.new(env)
            log = {}
            log["status"] = status_code
            log["path"] = request.path
            log["method"] = request.request_method
            log["params"] = params_filter(request.params).to_s
            ua = Woothee.parse(request.user_agent)
            log["device"] = ua[:category]
            log["os"] = ua[:os]
            log["browser"] = ua[:name]
            log["browser_ver"] = ua[:version]
            log["user_agent"] = request.user_agent
            log["remote_ip"] = request.ip
            access_time = Time.now.to_i
            log["time"] = access_time
            log["accessed_at"] = access_time
            log
          end

          private

          def initialize_filter_params(filter_items)
            filter_strings = []
            filter_strings << Rack::Access::Capture::DEFAULT_FILTER_PARAMS
            filter_strings << filter_items.map(&:to_s)
            filter_strings.flatten!.uniq
            filter_strings.map { |item| Regexp.compile(Regexp.escape(item.to_s)) }
          end

          def params_filter(params)
            filtered_params = {}

            params.each do |key, value|
              if @filter_params.any? { |filter| key =~ filter }
                value = Rack::Access::Capture::FILTERED
              elsif value.is_a?(Hash)
                value = params_filter(value)
              elsif value.is_a?(Array)
                value = value.map { |v| v.is_a?(Hash) ? params_filter(v) : v }
              end

              filtered_params[key] = value
            end

            filtered_params
          end
        end
      end
    end
  end
end
