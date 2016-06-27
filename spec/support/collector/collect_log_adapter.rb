class CollectLogAdapter < Rack::Access::Capture::Collector::AbstractAdapter
  attr_accessor :collected_log

  def initialize(options)
  end

  def collect?(env)
    true
  end

  def collect(log)
    @collected_log = log
  end
end
