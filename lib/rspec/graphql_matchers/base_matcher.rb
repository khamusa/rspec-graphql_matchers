# frozen_string_literal: true

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
        expected_type.nil? || type_name(expected_type) == type_name(actual_type)
      end

      def type_name(a_type)
        a_type = a_type.to_type_signature if a_type.respond_to?(:to_type_signature)

        a_type.to_s
      end
    end
  end
end
