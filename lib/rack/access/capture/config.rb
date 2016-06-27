require 'rack/access/capture/collector/adapters'
require 'rack/access/capture/watcher/adapters'
require 'rack/access/capture/watcher/internal_watcher_adapter'

module Rack
  module Access
    module Capture
      class Config

        attr_reader :_collector, :_watcher, :_internal_watcher

        class << self
          def config_accessor(*names)
            names.each do |name|
              class_eval <<-METHOD
                def #{name}
                  @#{name}
                end

                def #{name}=(value)
                  @#{name} = value
                  if "#{name}" == "filter"
                    @_internal_watcher = Rack::Access::Capture::Watcher::InternalWatcherAdapter.new(convert_hash(value))
                  else
                    @_#{name} = Object.const_get("Rack::Access::Capture::#{name.capitalize}::Adapters").send("interpret_#{name}", convert_hash(value))
                  end
                end
              METHOD
            end
          end

          private :config_accessor
        end

        config_accessor :collector, :watcher, :filter

        def initialize(config = {})
          convertd_config = convert_hash(config)

          self.collector = convertd_config["collector"] if convertd_config.key?("collector")
          self.watcher = convertd_config["watcher"] if convertd_config.key?("watcher")
          self.filter = convertd_config["filter"]
        end

        private

        def convert_hash(hash)
          return {} if hash.nil?
          return hash unless hash.is_a?(Hash)

          converted_hash = {}

          hash.each do |key, value|
            key = key.to_s if key.is_a?(Symbol)

            if value.is_a?(Hash)
              value = convert_hash(value)
            elsif value.is_a?(Array)
              value = value.map { |v| v.is_a?(Hash) ? convert_hash(v) : v }
            end

            converted_hash[key] = value
          end

          converted_hash
        end
      end
    end
  end
end
