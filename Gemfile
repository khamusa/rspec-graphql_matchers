# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-graphql_matchers.gemspec
gemspec

# rubocop:disable Bundle/DuplicatedGem
if ENV['GRAPHQL_GEM_VERSION'] == '1.8'
  gem 'graphql', '~> 1.8.0'
elsif ENV['GRAPHQL_GEM_VERSION'] == '1.9'
  gem 'graphql', '~> 1.9.0'
end
# rubocop:enable Bundle/DuplicatedGem
