require_relative 'base_matcher'

module RSpec
  module GraphqlMatchers
    class HaveAField < BaseMatcher
      def initialize(expected_field_name)
        @expected_field_name = expected_field_name.to_s
        @expected_field_type = @graph_object = nil
        @fields = :fields
      end

      def matches?(graph_object)
        @graph_object = graph_object

        @actual_field = field_collection[@expected_field_name]
        valid_field? && types_match?(@actual_field.type, @expected_field_type)
      end

      def that_returns(expected_field_type)
        @expected_field_type = expected_field_type

        self
      end
      alias returning that_returns
      alias of_type that_returns

      def failure_message
        "expected #{describe_obj(@graph_object)} to " \
          "#{description}, #{explanation}."
      end

      def description
        "define field `#{@expected_field_name}`" + of_type_description
      end

      private

      def explanation
        return 'but no field was found with that name' unless @actual_field

        "but the field type was `#{@actual_field.type}`"
      end

      def valid_field?
        unless @expected_field_type.nil? || @actual_field.respond_to?(:type)
          error_msg = "The `#{@expected_field_name}` field defined by the GraphQL " \
          'object does\'t seem valid as it does not respond to #type. ' \
          "\n\n\tThe field found was #{@actual_field.inspect}. "
          puts error_msg
          raise error_msg
        end

        @actual_field
      end

      def of_type_description
        return '' unless @expected_field_type

        " of type `#{@expected_field_type}`"
      end

      def describe_obj(field)
        field.respond_to?(:name) && field.name || field.inspect
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
        klass = self.class.to_s.split('::').last

        # Copied these from: https://github.com/rails/rails/blob/v4.2.7.1/activesupport/lib/active_support/inflector/methods.rb#L95-L96
        klass.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        klass.gsub!(/([a-z\d])([A-Z])/, '\1_\2')

        klass.downcase!
      end
    end
  end
end
