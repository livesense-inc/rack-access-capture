require 'spec_helper'

describe Rack::Access::Capture::Watcher::Adapters do

  subject(:adapters) { Rack::Access::Capture::Watcher::Adapters }

  describe 'my watcher' do
    it { expect(adapters.interpret_watcher("adapter" => 'RequestWatcherAdapter')).to be_a_kind_of(RequestWatcherAdapter) }

    context 'parameter error' do
      it { expect(adapters.interpret_watcher("adapter" => 'TestAdapter')).to be_nil }
      it { expect(adapters.interpret_watcher(nil)).to be_nil }
      it { expect(adapters.interpret_watcher({})).to be_nil }
    end

    context 'not implements method' do
      it { expect(adapters.interpret_watcher("adapter" => 'ErrorWatcherAdapter')).to be_nil }
    end
  end
end
