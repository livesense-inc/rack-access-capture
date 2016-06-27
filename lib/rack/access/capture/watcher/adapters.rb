module Rack
  module Access
    module Capture
      module Watcher

        class Adapters

          WATCHER_ADAPTER_METHODS = %w(request_capture response_capture).freeze

          private_constant :WATCHER_ADAPTER_METHODS

          class << self
            def interpret_watcher(config)
              class_name = config["adapter"] if !config.nil? && config.is_a?(Hash) && config.key?("adapter")

              if class_name.is_a?(String)
                with_ignoring_name_error do
                  object = Object.const_get(class_name).new
                  watcher_adapter?(object) ? object : nil
                end
              end
            end

            private

            def watcher_adapter?(object)
              WATCHER_ADAPTER_METHODS.all? { |method_name| object.respond_to?(method_name) }
            end

            def with_ignoring_name_error(&block)
              proc {
                begin
                  yield
                rescue NameError
                  nil
                end
              }.call
            end
          end
        end
      end
    end
  end
end
