require 'spec_helper'

describe Rack::Access::Capture::Collector::Adapters do

  let(:logger) { ->(_tag, _log) { '' } }

  before { allow(Fluent::Logger::FluentLogger).to receive(:new).and_return(logger) }

  subject(:adapters) { Rack::Access::Capture::Collector::Adapters }

  describe 'built in adapter' do
    context 'fluentd' do
      it { expect(adapters.interpret_collector("adapter" => :fluentd)).to be_a_kind_of(Rack::Access::Capture::Collector::FluentdAdapter) }
    end

    context 'console' do
      it { expect(adapters.interpret_collector("adapter" => :console)).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
    end

    context 'not found' do
      it { expect(adapters.interpret_collector("adapter" => :other)).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
    end
  end

  describe 'my collector' do
    it { expect(adapters.interpret_collector("adapter" => 'TestCollectLogAdapter', "config" => {})).to be_a_kind_of(TestCollectLogAdapter) }

    context 'not implements method' do
      before do
        class TestCollectLogAdapter
          instance_methods.each do |m|
            undef_method m if m.to_s =~ /collect?|collect/
          end
        end
      end

      it { expect(adapters.interpret_collector("adapter" => 'TestCollectLogAdapter')).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
    end

    context 'not exist adapter' do
      it { expect(adapters.interpret_collector("adapter" => 'MyAdapter')).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
    end
  end

  context 'parameter error' do
    it { expect(adapters.interpret_collector({})).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
    it { expect(adapters.interpret_collector(1)).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
    it { expect(adapters.interpret_collector(nil)).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
  end
end
