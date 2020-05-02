# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'rspec/graphql_matchers'
# rubocop:disable Style/MixinUsage
include RSpec::GraphqlMatchers::TypesHelper
# rubocop:enable Style/MixinUsage

module RSpec
  module Matchers
    def fail_with(message)
      raise_error(RSpec::Expectations::ExpectationNotMetError, message)
    end
  end
end
