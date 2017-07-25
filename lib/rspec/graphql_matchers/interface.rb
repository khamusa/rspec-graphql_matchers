require_relative 'base_matcher'

module RSpec
  module GraphqlMatchers
    class Interface < BaseMatcher
      def initialize(interface_names)
        @expected = interface_names.map(&:to_s)
      end

      def matches?(graph_object)
        @graph_object = graph_object
        @actual = actual
        @expected.each do |name|
          return false unless @actual.include?(name)
        end
      end

      def failure_message
        message  = "expected interfaces: #{@expected.join(', ')}\n"
        message += "actual interfaces:   #{@actual.join(', ')}"
        message
      end

      def failure_message_when_negated
        message  = "unexpected interfaces: #{@expected.join(', ')}\n"
        message += "actual interfaces:     #{@actual.join(', ')}"
        message
      end

      def description
        "interface #{@expected.join(', ')}"
      end

      private

      def actual
        if @graph_object.respond_to?(:interfaces)
          @graph_object.interfaces.map(&:to_s)
        else
          raise "Invalid object #{@graph_object} provided to #{matcher_name} " \
            'matcher. It does not seem to be a valid GraphQL object type.'
        end
      end
    end
  end
end
