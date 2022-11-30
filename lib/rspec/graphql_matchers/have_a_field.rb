# frozen_string_literal: true

require_relative 'base_matcher'
require_relative './have_a_field_matchers/of_type'
require_relative './have_a_field_matchers/with_property'
require_relative './have_a_field_matchers/with_metadata'
require_relative './have_a_field_matchers/with_hash_key'
require_relative './have_a_field_matchers/with_deprecation_reason'

module RSpec
  module GraphqlMatchers
    class HaveAField < BaseMatcher
      def initialize(expected_field_name, fields = :fields)
        @expected_field_name = expected_field_name.to_s
        @expected_camel_field_name = GraphQL::Schema::Member::BuildType.camelize(
          @expected_field_name
        )
        @fields = fields.to_sym
        @expectations = []
      end

      def matches?(graph_object)
        @graph_object = graph_object

        return false if actual_field.nil?

        @results = @expectations.reject do |matcher|
          matcher.matches?(actual_field)
        end

        @results.empty?
      end

      def that_returns(expected_field_type)
        @expectations << HaveAFieldMatchers::OfType.new(expected_field_type)
        self
      end

      alias returning that_returns
      alias of_type that_returns

      def with_property(expected_property_name)
        @expectations << HaveAFieldMatchers::WithProperty.new(expected_property_name)
        self
      end

      def with_hash_key(expected_hash_key)
        @expectations << HaveAFieldMatchers::WithHashKey.new(expected_hash_key)

        self
      end

      def with_metadata(expected_metadata)
        @expectations << HaveAFieldMatchers::WithMetadata.new(expected_metadata)
        self
      end

      def with_deprecation_reason(expected_reason = nil)
        @expectations << HaveAFieldMatchers::WithDeprecationReason.new(expected_reason)
        self
      end

      def failure_message
        base_msg = "expected #{member_name(@graph_object)} " \
          "to define field `#{@expected_field_name}`" \

        return "#{base_msg} #{failure_messages.join(', ')}" if actual_field

        "#{base_msg} but no field was found with that name"
      end

      def description
        ["define field `#{@expected_field_name}`"].concat(descriptions).join(', ')
      end

      private

      def actual_field
        @actual_field ||= begin
          field = field_collection[@expected_field_name]
          field ||= field_collection[@expected_camel_field_name]

          field.respond_to?(:to_type_signature) ? field.to_type_signature : field
        end
      end

      def descriptions
        @results.map(&:description)
      end

      def failure_messages
        @results.map(&:failure_message)
      end

      def field_collection
        if @graph_object.respond_to?(@fields)
          @graph_object.public_send(@fields)
        else
          raise "Invalid object #{@graph_object} provided to #{matcher_name} " \
            'matcher. It does not seem to be a valid GraphQL object type.'
        end
      end

      def matcher_name
        case @fields
        when :fields        then 'have_a_field'
        when :input_fields  then 'have_an_input_field'
        when :return_fields then 'have_a_return_field'
        end
      end
    end
  end
end
