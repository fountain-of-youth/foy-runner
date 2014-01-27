# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foy_runner/version'

Gem::Specification.new do |spec|
  spec.name          = "foy_runner"
  spec.version       = Foy::Runner::VERSION
  spec.authors       = ["Roberto Soares"]
  spec.email         = ["contact@robertosoares.me"]
  spec.summary       = %q{Foy Runner}
  spec.description   = %q{Foy Runner}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 2.14.1"

  spec.add_dependency "foy_api_client"
  spec.add_dependency "foy_ruby_handler"
end
