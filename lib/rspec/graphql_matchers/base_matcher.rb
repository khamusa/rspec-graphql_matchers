module RSpec
  module GraphqlMatchers
    class BaseMatcher
      private

      def types_match?(actual_type, expected_type)
        expected_type.nil? || expected_type.to_s == actual_type.to_s
      end
    end
  end
end
