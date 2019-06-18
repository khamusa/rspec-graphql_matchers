module RSpec
  module GraphqlMatchers
    class BaseMatcher
      private

      def member_name(member)
        member.respond_to?(:graphql_name) && member.graphql_name ||
          member.respond_to?(:name) && member.name ||
          member.inspect
      end

      def types_match?(actual_type, expected_type)
        actual_type = actual_type.to_graphql if actual_type.respond_to?(:to_graphql)
        expected_type = expected_type.to_graphql if expected_type.respond_to?(:to_graphql)

        expected_type.nil? || expected_type.to_s == actual_type.to_s
      end
    end
  end
end
