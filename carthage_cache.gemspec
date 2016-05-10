# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carthage_cache/version'
require 'carthage_cache/description'

Gem::Specification.new do |spec|
  spec.name          = "carthage_cache"
  spec.version       = CarthageCache::VERSION
  spec.authors       = ["Guido Marucci Blas"]
  spec.email         = ["guidomb@gmail.com"]

  spec.summary       = CarthageCache::DESCRIPTION
  spec.description   = %q{
    CarthageCache generate a hash key based on the content of your Cartfile.resolved and checks
    if there is a cache archive (a zip file of your Carthage/Build directory) associated to that hash.
    If there is one it will download it and install it in your project avoiding the need to run carthage bootstrap.
  }
  spec.homepage      = "https://github.com/guidomb/carthage_cache"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "codeclimate-test-reporter"

  spec.add_dependency "aws-sdk", "~> 2.2.3"
  spec.add_dependency "commander", "~> 4.3"
end
