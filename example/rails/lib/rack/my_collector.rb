require 'rack-access-capture'

module Rack
  class MyCollector < Rack::Access::Capture::Collector::AbstractAdapter

    def initialize(options)
      @log_file = options['file_path']
    end

    def collect?(env)
      true
    end

    def collect(log)
      open(@log_file, 'a') do |file|
         file.puts(log)
      end
    end
  end
end
