lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/access/capture/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-access-capture'
  spec.version       = Rack::Access::Capture::VERSION
  spec.authors       = ['moonstruckdrops']
  spec.email         = ['moonstruckdrops@gmail.com']

  spec.summary       = 'To capture the request and response in the rack middleware, you can be output to any destination.'
  spec.description   = 'To capture the request and response in the rack middleware, you can be output to any destination.'
  spec.homepage      = 'https://github.com/livesense-inc/rack-access-capture'
  spec.license       = 'MIT'

  spec.files         = ['rack-access-capture.gemspec'].concat(Dir.glob('lib/**/*').reject { |f| File.directory?(f) || f =~ /~$/ })
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency 'woothee', '~> 1.4'
  spec.add_dependency 'fluent-logger', ['>= 0.5.1', '< 0.7.0']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'rack-test', '~> 0.6.3'
  spec.add_development_dependency 'rubocop', '~> 0.40.0'
end
