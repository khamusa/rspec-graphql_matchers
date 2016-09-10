require 'rspec/matchers'
require 'rspec/graphql_matchers/be_of_type'

module RSpec
  module Matchers
    def be_of_type(expected)
      RSpec::GraphqlMatchers::BeOfType.new(expected)
    end
  end
end
