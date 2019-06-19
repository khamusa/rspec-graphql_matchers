require_relative 'base_matcher'

module RSpec
  module GraphqlMatchers
    class Implement < BaseMatcher
      def initialize(interfaces)
        @expected = interfaces.map {|interface| interface_name(interface) }
      end

      def matches?(graph_object)
        @graph_object = graph_object
        @actual = actual
        @expected.all? { |name| @actual.include?(name) }
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
        "implement #{@expected.join(', ')}"
      end

      private

      def actual
        if @graph_object.respond_to?(:interfaces)
          return @graph_object.interfaces.map do |interface|
            interface_name(interface)
          end
        end

        raise "Invalid object #{@graph_object} provided to #{matcher_name} " \
          'matcher. It does not seem to be a valid GraphQL object type.'
      end

      def interface_name(interface)
        return interface.graphql_name if interface.respond_to?(:graphql_name)

        interface.to_s
      end
    end
  end
end
