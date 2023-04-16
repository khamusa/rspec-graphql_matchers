# frozen_string_literal: true

require 'graphql'

module RSpec
  module GraphqlMatchers
    module TypesHelper

      class << self
        extend Gem::Deprecate

        GraphQL::Types.constants.each do |constant_name|
          klass = GraphQL::Types.const_get(constant_name)

          define_method(constant_name) { klass }

          deprecate constant_name, "GraphQL::Types::#{constant_name}", 2023, 10
        end
      end

      def types
        TypesHelper
      end
    end
  end
end
