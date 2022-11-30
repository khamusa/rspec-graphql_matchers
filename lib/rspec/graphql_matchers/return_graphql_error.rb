require_relative 'base_matcher'

module RSpec
  module GraphqlMatchers
    class ReturnGraphqlError < BaseMatcher
      attr_reader :errors, :expected

      def initialize(expected = nil)
        @expected = expected
      end

      def matches?(resolved_data)
        @errors = resolved_data['errors']
        @resolved_data = resolved_data.to_h

        return false if no_errors?

        return unless @expected
        if @expected.is_a? Regexp
          @errors.any? { |error| error['message'] =~ @expected }
        else
          @errors.any? { |error| error['message'] == @expected }
        end
      end

      def no_errors?
        @errors.nil? || @errors.empty?
      end

      def failure_message
        if no_errors?
          if @expected
            "Expected to find an error with message `#{@expected}`, " \
            "but there were no errors in: `#{@resolved_data}`"
          else
            'Expected to find errors, but there were no errors.'
          end
        else
          "Expected result to have an error message `#{@expected}`, " \
          "but there were no errors in: `#{@resolved_data}`"
        end
      end
    end
  end
end
