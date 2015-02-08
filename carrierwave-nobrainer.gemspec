# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/nobrainer/version'

Gem::Specification.new do |spec|
  spec.name          = "carrierwave-nobrainer"
  spec.version       = Carrierwave::Nobrainer::VERSION
  spec.authors       = ["Paweł Świątkowski"]
  spec.email         = ["inquebrantable@gmail.com"]
  spec.summary       = %q{Adds support for NoBrainer to CarrierWave}
  spec.homepage      = "https://github.com/katafrakt/carrierwave-nobrainer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nobrainer", '>= 0.17.0'
  spec.add_dependency "carrierwave"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
