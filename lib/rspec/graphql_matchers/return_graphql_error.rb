require_relative 'base_matcher'

module RSpec
  module GraphqlMatchers
    class ReturnGraphqlError < BaseMatcher
      attr_reader :errors, :expected_error_message

      def initialize(expected_error_message = nil)
        @expected_error_message = expected_error_message
      end

      def matches?(resolved_data)
        @errors = resolved_data['errors']
        @resolved_data = resolved_data.to_h
        return false if @errors.nil? || @errors.empty?

        if @expected_error_message
          if @expected_error_message.is_a? Regexp
            @errors.any? { |error| error['message'] =~ @expected_error_message }
          else
            @errors.any? { |error| error['message'] == @expected_error_message }
          end
        end
      end

      def failure_message
        if @errors.nil? || @errors.empty?
          if @expected_error_message
            "Expected to find an error with message `#{@expected_error_message}`, but there were no errors in: `#{@resolved_data}`"
          else
            "Expected to find errors, but there were no errors."
          end
        else
          "Expected result to have an error message `#{@expected_error_message}`, but there were no errors in: `#{@resolved_data}`"
        end
      end
    end
  end
end
