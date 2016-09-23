# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alephant/logger/json/version'

Gem::Specification.new do |spec|
  spec.name          = 'alephant-logger-json'
  spec.version       = Alephant::Logger::JSON::VERSION
  spec.authors       = ['Dan Arnould']
  spec.email         = ['dan@arnould.co.uk']
  spec.summary       = 'alephant-logger driver enabling structured logging in JSON'
  spec.description   = 'alephant-logger driver enabling structured logging in JSON'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-nc'
  spec.add_development_dependency 'rake-rspec'
  spec.add_development_dependency 'pry'
end
