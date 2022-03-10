# frozen_string_literal: true

require_relative 'base_matcher'
require_relative './have_a_field_matchers/of_type'
require_relative './have_a_field_matchers/with_deprecation_reason'

module RSpec
  module GraphqlMatchers
    class AcceptArgument < BaseMatcher
      def initialize(expected_arg_name)
        @expectations = []

        if expected_arg_name.is_a?(Hash)
          (expected_arg_name, expected_type) = expected_arg_name.to_a.first
          of_type(expected_type)

          warn 'DEPRECATION WARNING: using accept_arguments with a hash will be '\
               'deprecated on the next major release. Use the format ' \
               "`accept_argument(:argument_name).of_type('ExpectedType!') instead.`"
        end

        @expected_arg_name = expected_arg_name.to_s
        @expected_camel_arg_name = GraphQL::Schema::Member::BuildType.camelize(
          @expected_arg_name
        )
      end

      def matches?(graph_object)
        @graph_object = graph_object

        @actual_argument = field_arguments[@expected_arg_name]
        @actual_argument ||= field_arguments[@expected_camel_arg_name]
        return false if @actual_argument.nil?

        @results = @expectations.reject do |matcher|
          matcher.matches?(@actual_argument)
        end

        @results.empty?
      end

      def of_type(expected_field_type)
        @expectations << HaveAFieldMatchers::OfType.new(expected_field_type)
        self
      end

      def with_deprecation_reason(expected_reason = nil)
        @expectations << HaveAFieldMatchers::WithDeprecationReason.new(expected_reason)
        self
      end

      def failure_message
        base_msg = "expected #{member_name(@graph_object)} " \
          "to accept argument `#{@expected_arg_name}`" \

        return "#{base_msg} #{failure_messages.join(', ')}" if @actual_argument

        "#{base_msg} but no argument was found with that name"
      end

      def description
        ["accept argument `#{@expected_arg_name}`"].concat(descriptions).join(', ')
      end

      private

      def descriptions
        @results.map(&:description)
      end

      def failure_messages
        @results.map(&:failure_message)
      end

      def field_arguments
        if @graph_object.respond_to?(:arguments)
          @graph_object.public_send(:arguments)
        else
          raise "Invalid object #{@graph_object} provided to accept_argument " \
            'matcher. It does not seem to be a valid GraphQL object type.'
        end
      end
    end
  end
end
