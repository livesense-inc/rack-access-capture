require 'spec_helper'

describe Rack::Access::Capture::Manager do

  let(:app) { ->(_env) { expect_response } }
  let(:expect_response) { [200, { 'Content-Type' => '' }, ''] }
  let(:logger) { ->(_tag, _log) { '' } }

  before { allow(Fluent::Logger::FluentLogger).to receive(:new).and_return(logger) }

  describe 'initializer' do
    shared_examples_for 'initialized collector and watcher' do
      it { expect(manager.config._collector).to be_a_kind_of(Rack::Access::Capture::Collector::FluentdAdapter) }
      it { expect(manager.config._watcher).to be_a_kind_of(RequestAndResponseWatcherAdapter) }
    end

    context 'allow the hash' do
      let(:manager) do
        Rack::Access::Capture::Manager.new(app, collector: { adapter: :fluentd,
                                                             config: { tag: 'rack_access_capture' } },
                                                watcher: { adapter: 'RequestAndResponseWatcherAdapter' })
      end

      it_behaves_like 'initialized collector and watcher'
    end

    context 'allow the yaml' do
      let(:manager) do
        Rack::Access::Capture::Manager.new(app, YAML.load(<<-YAML
                                                            collector:
                                                              adapter: :fluentd
                                                              config:
                                                                tag: rack_access_capture
                                                            watcher:
                                                              adapter: 'RequestAndResponseWatcherAdapter'
                                                            filter:
                                                              params:
                                                                - email
                                                                - name
                                                          YAML
                                                         ))
      end

      it_behaves_like 'initialized collector and watcher'
    end

    context 'allow the block' do
      let(:manager) do
        Rack::Access::Capture::Manager.new(app, {}) do |config|
          config.collector = { "adapter" => :fluentd }
          config.watcher = { "adapter" => 'RequestAndResponseWatcherAdapter' }
        end
      end

      it_behaves_like 'initialized collector and watcher'
    end
  end

  describe 'collect the capture log' do
    let(:user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" }
    let(:accessed_at) { Time.now }

    shared_examples_for 'no processing in the response' do
      it { expect(middleware.call(request)).to eq expect_response }
    end

    shared_examples_for 'captured the default access log' do
      it { expect(middleware.config._collector.collected_log).to include("status" => 200,
                                                                         "path" => "/",
                                                                         "device" => :pc,
                                                                         "os" => "Mac OSX",
                                                                         "browser" => "Chrome",
                                                                         "browser_ver" => "50.0.2661.102",
                                                                         "user_agent" => \
                                                                           "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36",
                                                                         "remote_ip" => nil,
                                                                         "time" => accessed_at.to_i,
                                                                         "accessed_at" => accessed_at.to_i)
      }
    end

    context 'default capture' do
      let(:request) { Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent) }
      let(:middleware) { Rack::Access::Capture::Manager.new(app, collector: { adapter: 'CollectLogAdapter' }) }
      before { middleware.call(request) }

      it_behaves_like 'no processing in the response'
      it_behaves_like 'captured the default access log'
      it { expect(middleware.config._collector.collected_log).to include("method" => "GET", "params" => "{}") }
    end

    context 'request capture' do
      let(:request) { Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent, method: 'POST', params: { filter1: 'param1', filter2: 'param2' }) }
      let(:middleware) { Rack::Access::Capture::Manager.new(app, collector: { adapter: 'CollectLogAdapter' }, watcher: { adapter: 'RequestWatcherAdapter' }) }
      before { middleware.call(request) }

      it_behaves_like 'no processing in the response'
      it_behaves_like 'captured the default access log'
      it { expect(middleware.config._collector.collected_log).to include("method" => "POST", "params" => "{\"filter1\"=>\"param1\", \"filter2\"=>\"param2\"}") }
      it { expect(middleware.config._collector.collected_log).to include(:rails_action => "index") }
    end

    context 'response capture' do
      let(:request) { Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent, method: 'PUT', params: { filter1: 'param1', filter2: 'param2' }) }
      let(:middleware) { Rack::Access::Capture::Manager.new(app, collector: { adapter: 'CollectLogAdapter' }, watcher: { adapter: 'ResponseWatcherAdapter' }) }
      before { middleware.call(request) }

      it_behaves_like 'no processing in the response'
      it_behaves_like 'captured the default access log'
      it { expect(middleware.config._collector.collected_log).to include("method" => "PUT", "params" => "{\"filter1\"=>\"param1\", \"filter2\"=>\"param2\"}") }
      it { expect(middleware.config._collector.collected_log).to include(:response_data => "response data") }
    end

    context 'request and response capture' do
      let(:request) { Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent, method: 'DELETE', params: { id: '100' }) }
      let(:middleware) { Rack::Access::Capture::Manager.new(app, collector: { adapter: 'CollectLogAdapter' }, watcher: { adapter: 'RequestAndResponseWatcherAdapter' }) }
      before { middleware.call(request) }

      it_behaves_like 'no processing in the response'
      it_behaves_like 'captured the default access log'
      it { expect(middleware.config._collector.collected_log).to include("method" => "DELETE", "params" => "{\"id\"=>\"100\"}") }
      it { expect(middleware.config._collector.collected_log).to include(:response_data => "response data") }
    end

    context 'other formatted capture' do
      let(:request) { Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent) }
      let(:middleware) { Rack::Access::Capture::Manager.new(app, collector: { adapter: 'CollectLogAdapter' }, watcher: { adapter: 'OtherFormatWatcherAdapter' }) }
      before { middleware.call(request) }

      it_behaves_like 'no processing in the response'
      it_behaves_like 'captured the default access log'
      it { expect(middleware.config._collector.collected_log).to include(:request => "100", response: "response capture") }
    end
  end

  describe 'not collect the capture log' do
    let(:request) { Rack::MockRequest.env_for("/") }

    shared_examples_for 'no processing in the response' do
      it { expect(middleware.call(request)).to eq expect_response }
    end

    context 'default config' do
      let(:middleware) { Rack::Access::Capture::Manager.new(app, nil) }
      it_behaves_like 'no processing in the response'
    end

    context 'collector config' do
      let(:middleware) { Rack::Access::Capture::Manager.new(app, collector: { adapter: '' }) }
      before { allow_any_instance_of(Rack::Access::Capture::Collector::ConsoleAdapter).to receive(:collect).and_return('') }
      it_behaves_like 'no processing in the response'
    end
  end
end
