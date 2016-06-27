require "rack/access/capture/version"
require "rack/access/capture/config"
require "rack/access/capture/manager"
require "rack/access/capture/collector/abstract_adapter"
require "rack/access/capture/watcher/base_adapter"

module Rack
  module Access
    module Capture
      # parameter filter
      FILTERED = '[FILTERED]'.freeze
      DEFAULT_FILTER_PARAMS = %w(password authenticity_token).freeze
      # HTTP method
      GET     = 'GET'.freeze
      POST    = 'POST'.freeze
      PUT     = 'PUT'.freeze
      PATCH   = 'PATCH'.freeze
      DELETE  = 'DELETE'.freeze
      HEAD    = 'HEAD'.freeze
      OPTIONS = 'OPTIONS'.freeze
      LINK    = 'LINK'.freeze
      UNLINK  = 'UNLINK'.freeze
      TRACE   = 'TRACE'.freeze
    end
  end
end
