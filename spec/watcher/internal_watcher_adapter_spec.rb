require 'spec_helper'

describe Rack::Access::Capture::Watcher::InternalWatcherAdapter do

  let(:status) { 200 }
  let(:header) do
    { "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "1; mode=block", "X-Content-Type-Options" => "nosniff", "Content-Type" => "text/html; charset=utf-8" }
  end
  let(:user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" }
  let(:accessed_at) { Time.now }
  before { allow(Time).to receive(:now).and_return(accessed_at) }

  shared_examples_for 'captured request' do
    it { expect(subject.access_log(env, status, header)).to include("status" => 200,
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

  describe 'default filter' do
    subject { Rack::Access::Capture::Watcher::InternalWatcherAdapter.new }

    context 'get request' do
      let(:env) { Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent) }
      it_behaves_like 'captured request'
      it { expect(subject.access_log(env, status, header)).to include("method" => "GET", "params" => "{}") }
    end

    context 'post request' do
      let(:env) do
        Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent, method: 'POST', params: { password: 'your_password',
                                                                                                  authenticity_token: 'your_token' })
      end
      it_behaves_like 'captured request'
      it { expect(subject.access_log(env, status, header)).to include("method" => "POST", "params" => "{\"password\"=>\"[FILTERED]\", \"authenticity_token\"=>\"[FILTERED]\"}") }
    end
  end

  describe 'user difined filter' do
    let(:env) { Rack::MockRequest.env_for("/", 'HTTP_USER_AGENT' => user_agent, method: 'POST', params: { filter1: 'param1', filter2: 'param2' }) }
    subject { Rack::Access::Capture::Watcher::InternalWatcherAdapter.new("params" => %w(filter1 filter2)) }
    it_behaves_like 'captured request'
    it { expect(subject.access_log(env, status, header)).to include("method" => "POST", "params" => "{\"filter1\"=>\"[FILTERED]\", \"filter2\"=>\"[FILTERED]\"}") }
  end
end
