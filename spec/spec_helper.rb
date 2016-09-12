$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec/graphql_matchers'

include RSpec::GraphqlMatchers::TypesHelper

module RSpec
  module Matchers
    def fail_with(message)
      raise_error(RSpec::Expectations::ExpectationNotMetError, message)
    end
  end
end
