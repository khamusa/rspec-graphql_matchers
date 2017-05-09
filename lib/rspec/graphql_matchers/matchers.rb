require 'rspec/matchers'
require 'rspec/graphql_matchers/be_of_type'
require 'rspec/graphql_matchers/accept_arguments'
require 'rspec/graphql_matchers/have_a_field'
require 'rspec/graphql_matchers/have_an_input_field'
require 'rspec/graphql_matchers/have_a_return_field'

module RSpec
  module Matchers
    def be_of_type(expected)
      RSpec::GraphqlMatchers::BeOfType.new(expected)
    end

    def accept_arguments(expected_args)
      RSpec::GraphqlMatchers::AcceptArguments.new(expected_args)
    end
    alias accept_argument accept_arguments

    # rubocop:disable Style/PredicateName
    def have_a_field(field_name)
      RSpec::GraphqlMatchers::HaveAField.new(field_name)
    end
    alias have_field have_a_field

    # rubocop:disable Style/PredicateName
    def have_an_input_field(field_name)
      RSpec::GraphqlMatchers::HaveAnInputField.new(field_name)
    end
    alias have_input_field have_an_input_field

    # rubocop:disable Style/PredicateName
    def have_a_return_field(field_name)
      RSpec::GraphqlMatchers::HaveAReturnField.new(field_name)
    end
    alias have_return_field have_a_return_field
  end
end
