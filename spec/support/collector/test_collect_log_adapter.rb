class TestCollectLogAdapter < Rack::Access::Capture::Collector::AbstractAdapter

  def initialize(options)
  end

  def collect?(env); end

  def collect(log); end
end
