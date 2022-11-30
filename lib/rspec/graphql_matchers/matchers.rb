# frozen_string_literal: true

require 'rspec/matchers'
require 'rspec/graphql_matchers/be_of_type'
require 'rspec/graphql_matchers/accept_arguments'
require 'rspec/graphql_matchers/accept_argument'
require 'rspec/graphql_matchers/have_a_field'
require 'rspec/graphql_matchers/implement'
require 'rspec/graphql_matchers/return_graphql_error'

module RSpec
  module Matchers
    def be_of_type(expected)
      RSpec::GraphqlMatchers::BeOfType.new(expected)
    end

    def accept_argument(expected_argument)
      RSpec::GraphqlMatchers::AcceptArgument.new(expected_argument)
    end

    def accept_arguments(expected_args)
      RSpec::GraphqlMatchers::AcceptArguments.new(expected_args)
    end

    # rubocop:disable Naming/PredicateName
    def have_a_field(field_name)
      RSpec::GraphqlMatchers::HaveAField.new(field_name)
    end
    alias have_field have_a_field

    def have_an_input_field(field_name)
      RSpec::GraphqlMatchers::HaveAField.new(field_name, :input_fields)
    end
    alias have_input_field have_an_input_field

    def have_a_return_field(field_name)
      RSpec::GraphqlMatchers::HaveAField.new(field_name, :return_fields)
    end
    alias have_return_field have_a_return_field
    # rubocop:enable Naming/PredicateName

    def implement(*interface_names)
      RSpec::GraphqlMatchers::Implement.new(interface_names.flatten)
    end

    def return_graphql_error(expected)
      RSpec::GraphqlMatchers::ReturnGraphqlError.new(expected)
    end
  end
end
