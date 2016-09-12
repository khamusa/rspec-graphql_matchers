module RSpec
  module GraphqlMatchers
    module TypesHelper
      def types
        GraphQL::Define::TypeDefiner.instance
      end
    end
  end
end
