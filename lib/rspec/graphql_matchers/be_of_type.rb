# frozen_string_literal: true

require_relative 'base_matcher'

module RSpec
  module GraphqlMatchers
    class BeOfType < BaseMatcher
      attr_reader :sample, :expected

      def initialize(expected)
        @expected = expected
      end

      def matches?(actual_sample)
        @sample = to_graphql(actual_sample)
        sample.respond_to?(:type) && types_match?(sample.type, @expected)
      end

      def failure_message
        "expected field '#{member_name(sample)}' to be of type '#{expected}', " \
        "but it was '#{type_name(sample.type)}'"
      end

      def description
        "be of type '#{expected}'"
      end

      private

      def to_graphql(field_sample)
        return field_sample unless field_sample.respond_to?(:to_type_signature)

        field_sample.to_type_signature
      end
    end
  end
end
