module RSpec
  module GraphqlMatchers
    class BeOfType
      attr_reader :sample, :expected

      def initialize(expected)
        @expected = expected
      end

      def matches?(actual_sample)
        @sample = actual_sample
        @type = @sample.type.of_type.to_s.split("::")[-1]
        @type == @expected.to_s
      end

      def failure_message
        "expected field '#{field_name(sample)}' to be of type '#{expected}', " \
        "but it was '#{sample.type}'"
      end

      def description
        "be of type '#{expected}'"
      end

      private

      def field_name(field)
        field.respond_to?(:name) && field.name || field.inspect
      end
    end
  end
end
