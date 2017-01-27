require 'fluent-logger'
require "rack/access/capture/collector/abstract_adapter"

module Rack
  module Access
    module Capture
      module Collector

        class FluentdAdapter < AbstractAdapter

          attr_reader :tag

          def initialize(options = {})
            config = options || {}
            @tag = config["tag"] || 'development'
            tag_prefix = config["tag_prefix"]
            host = config["host"] || 'localhost'
            port = config["port"] || 24224
            handler = proc { |messages| BufferOverflowHandler.new(config["log_file_path"]).flush(messages) }
            buffer_limit = config["buffer_limit"] || 131072 # Buffer limit of the standard is 128.kilobyte
            log_reconnect_error_threshold = config["log_reconnect_error_threshold"] || Fluent::Logger::FluentLogger::RECONNECT_WAIT_MAX_COUNT
            options = { host: host,
                        port: port,
                        buffer_limit: buffer_limit,
                        buffer_overflow_handler: handler,
                        log_reconnect_error_threshold: log_reconnect_error_threshold }
            @logger = config["logger"] || Fluent::Logger::FluentLogger.new(tag_prefix, options)
            exclude_request = config["exclude_request"] || []
            @collect = [GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, LINK, UNLINK, TRACE] - exclude_request
            @exclude_ua_list = config["exclude_user_agents"] || []
          end

          def collect?(env)
            !@exclude_ua_list.include?(env["HTTP_USER_AGENT"]) && @collect.include?(env["REQUEST_METHOD"])
          end

          def collect(log)
            @logger.post(@tag, log)
          end
        end

        class BufferOverflowHandler

          def initialize(log_directory_path)
            @log_directory_path = log_directory_path
          end

          def flush(messages)
            return if @log_directory_path.nil?

            MessagePack::Unpacker.new.feed_each(messages) do |msg|
              open("#{@log_directory_path}/#{msg[0]}_#{msg[1]}.json", 'w') do |io|
                JSON.dump(msg[2], io)
              end
            end
          end
        end
      end
    end
  end
end
