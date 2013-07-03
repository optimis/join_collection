# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'join_collection'

Gem::Specification.new do |spec|
  spec.name          = "join_collection"
  spec.version       = JoinCollection::VERSION
  spec.authors       = ["Mason Chang"]
  spec.email         = ["changmason@gmail.com"]
  spec.description   = %q{Joining mongoid docs with specified relation}
  spec.summary       = %q{Joining mongoid docs with specified relation}
  spec.homepage      = "https://github.com/optimis/join_collection"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "mongoid"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
