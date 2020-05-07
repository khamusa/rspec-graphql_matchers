# frozen_string_literal: true

module RSpec
  module GraphqlMatchers
    module HaveAFieldMatchers
      class WithDeprecationReason
        def initialize(expected_reason)
          @expected_reason = expected_reason
        end

        def matches?(actual_field)
          @actual_reason = actual_field.deprecation_reason

          if @expected_reason.nil?
            !actual_field.deprecation_reason.nil?
          else
            actual_field.deprecation_reason == @expected_reason
          end
        end

        def failure_message
          message = "#{description}, but it was "
          message + (@actual_reason.nil? ? 'not deprecated' : "`#{@actual_reason}`")
        end

        def description
          if @expected_reason.nil?
            'with a deprecation reason'
          else
            "with deprecation reason `#{@expected_reason}`"
          end
        end
      end
    end
  end
end
