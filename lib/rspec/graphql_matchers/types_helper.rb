# frozen_string_literal: true

require 'graphql'

module RSpec
  module GraphqlMatchers
    module TypesHelper
      def types
        GraphQL::Define::TypeDefiner.instance
      end
    end
  end
end
