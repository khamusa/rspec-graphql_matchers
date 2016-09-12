# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/graphql_matchers/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-graphql_matchers'
  spec.version       = Rspec::GraphqlMatchers::VERSION
  spec.authors       = ['Samuel Brandão']
  spec.email         = ['gb.samuel@gmail.com']

  spec.summary       = 'Collection of rspec matchers to test your graphQL api schema.'
  spec.homepage      = 'https://github.com/khamusa/rspec-graphql_matchers'
  spec.license       = 'MIT'

  # raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency     'graphql', '>= 0.9', '< 1'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rubocop', '~> 0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0'
end
