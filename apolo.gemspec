# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apolo/version'

Gem::Specification.new do |spec|
  spec.name          = 'apolo'
  spec.version       = Apolo::VERSION
  spec.authors       = ['Efrén Fuentes', 'Thomas Vincent']
  spec.email         = ['thomasvincent@steelhouselabs.com']
  spec.summary       = %q{Metric, Monitoring & automation services framework.}
  spec.description   = %q{Metric, Monitoring & automation services framework.}
  spec.homepage      = ''
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]
  spec.required_rubygems_version = ">= 1.3.5"
  spec.summary = spec.description
  spec.test_files = Dir.glob("spec/**/*")
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_dependency 'sequel', '~> 4.14'
  spec.add_dependency 'sqlite3', '~> 1.3'
  spec.add_dependency 'cupsffi', '~> 0.1'
  spec.add_dependency "logger-better"
  spec.add_dependency "tnt"
end
