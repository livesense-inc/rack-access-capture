require 'rack/access/capture/collector/console_adapter'
require 'rack/access/capture/collector/fluentd_adapter'

module Rack
  module Access
    module Capture
      module Collector

        class Adapters

          BUILTIN_ADAPTERS = [:console, :fluentd].freeze
          COLLECTOR_ADAPTER_METHODS = ["collect?", "collect"].freeze
          SUFFIX_CLASS_NAME = "Adapter".freeze

          private_constant :BUILTIN_ADAPTERS, :COLLECTOR_ADAPTER_METHODS, :SUFFIX_CLASS_NAME

          class << self

            def interpret_collector(config)
              name_or_class = config["adapter"] if !config.nil? && config.is_a?(Hash) && config.key?("adapter")
              case name_or_class
              when Symbol
                collector_class = lookup(name_or_class)
                collector_class.nil? ? lookup(:console).new : collector_class.new(config["config"])
              when String
                console_adapter_in_case_of_name_error do
                  builtin_klass = lookup(name_or_class)
                  obj = builtin_klass.nil? ? Object.const_get(name_or_class).new(config["config"]) : builtin_klass.new(config["config"])
                  collector_adapter?(obj) ? obj : lookup(:console).new
                end
              else
                lookup(:console).new
              end
            end

            private

            def collector_adapter?(object)
              COLLECTOR_ADAPTER_METHODS.all? { |method_name| object.respond_to?(method_name) }
            end

            def lookup(name)
              return nil unless BUILTIN_ADAPTERS.include? name.to_sym
              const_get("Rack::Access::Capture::Collector::#{name.capitalize}#{SUFFIX_CLASS_NAME}")
            end

            def console_adapter_in_case_of_name_error(&block)
              proc {
                begin
                  yield
                rescue NameError
                  lookup(:console).new
                end
              }.call
            end
          end
        end
      end
    end
  end
end
