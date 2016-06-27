require 'spec_helper'

describe Rack::Access::Capture::Config do

  let(:logger) { ->(_tag, _log) { '' } }

  before { allow(Fluent::Logger::FluentLogger).to receive(:new).and_return(logger) }

  context 'should setup defaults' do
    let(:config) { Rack::Access::Capture::Config.new }

    it { expect(config._collector).to be_nil }
    it { expect(config._watcher).to be_nil }
    it { expect(config._internal_watcher).not_to be_nil }
  end

  context 'should setup with options' do
    let(:config) { Rack::Access::Capture::Config.new(collector: { adapter: :console }) }

    it { expect(config._collector).not_to be_nil }
    it { expect(config._watcher).to be_nil }
    it { expect(config._internal_watcher).not_to be_nil }
  end

  describe 'select collector adapter' do
    context 'should set the console adapter' do
      let(:config) { Rack::Access::Capture::Config.new(collector: { adapter: :console }) }

      it { expect(config._collector).to be_a_kind_of(Rack::Access::Capture::Collector::ConsoleAdapter) }
    end

    context 'should set the fluentd adapter' do
      context 'sholud set the default config' do
        let(:config) { Rack::Access::Capture::Config.new(collector: { adapter: :fluentd }) }

        it { expect(config._collector).to be_a_kind_of(Rack::Access::Capture::Collector::FluentdAdapter) }
        it { expect(config._collector.tag).to eq 'development' }
      end

      context 'should set the custom config' do
        let(:config) { Rack::Access::Capture::Config.new(collector: { adapter: :fluentd, config: { tag: 'rack_access_capture' } }) }

        it { expect(config._collector).to be_a_kind_of(Rack::Access::Capture::Collector::FluentdAdapter) }
        it { expect(config._collector.tag).to eq 'rack_access_capture' }
      end
    end
  end

  describe 'use custom watcher' do
    context 'should set the custom watcher' do
      let(:config) { Rack::Access::Capture::Config.new(watcher: { adapter: 'OtherFormatWatcherAdapter' }) }

      it { expect(config._watcher).to be_a_kind_of(OtherFormatWatcherAdapter) }
    end

    context 'should set the error custom watcher' do
      let(:config) { Rack::Access::Capture::Config.new(watcher: { adapter: 'ErrorWatcherAdapter' }) }

      it { expect(config._watcher).to be_nil }
    end
  end

  describe 'should set parameter filter' do
    let(:config) { Rack::Access::Capture::Config.new(filter: { params: %w(email name) }) }

    it { expect(config._internal_watcher.filter_params).to eq [/password/, /authenticity_token/, /email/, /name/] }
  end

  describe 'use yaml load' do
    shared_examples_for 'initialized collector and watcher' do
      it { expect(config._collector).to be_a_kind_of(Rack::Access::Capture::Collector::FluentdAdapter) }
      it { expect(config._collector.tag).to eq 'rack_access_capture' }
      it { expect(config._watcher).to be_a_kind_of(OtherFormatWatcherAdapter) }
      it { expect(config._internal_watcher.filter_params).to eq [/password/, /authenticity_token/, /email/, /name/] }
    end

    context 'set the builtin adapter by string' do
      let(:config) do
        Rack::Access::Capture::Config.new(YAML.load(<<-YAML
                                                      collector:
                                                        adapter: fluentd
                                                        config:
                                                          tag: rack_access_capture
                                                      watcher:
                                                        adapter: OtherFormatWatcherAdapter
                                                      filter:
                                                        params:
                                                          - email
                                                          - name
                                                    YAML
                                                   ))
      end

      it_behaves_like 'initialized collector and watcher'
    end

    context 'set the builtin adapter by symbol' do
      let(:config) do
        Rack::Access::Capture::Config.new(YAML.load(<<-YAML
                                                      collector:
                                                        adapter: :fluentd
                                                        config:
                                                          tag: rack_access_capture
                                                      watcher:
                                                        adapter: OtherFormatWatcherAdapter
                                                      filter:
                                                        params:
                                                          - email
                                                          - name
                                                    YAML
                                                   ))
      end
      it_behaves_like 'initialized collector and watcher'
    end

    context 'set the custom adapter' do
      let(:config) do
        Rack::Access::Capture::Config.new(YAML.load(<<-YAML
                                                      collector:
                                                        adapter: CollectLogAdapter
                                                        config:
                                                          tag: rack_access_capture
                                                      watcher:
                                                        adapter: OtherFormatWatcherAdapter
                                                      filter:
                                                        params:
                                                          - email
                                                          - name
                                                    YAML
                                                   ))
      end

      it { expect(config._collector).to be_a_kind_of(CollectLogAdapter) }
      it { expect(config._watcher).to be_a_kind_of(OtherFormatWatcherAdapter) }
      it { expect(config._internal_watcher.filter_params).to eq [/password/, /authenticity_token/, /email/, /name/] }
    end
  end
end
