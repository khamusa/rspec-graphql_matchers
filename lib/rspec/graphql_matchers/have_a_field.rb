require_relative 'base_matcher'

module RSpec
  module GraphqlMatchers
    class HaveAField < BaseMatcher
      def initialize(expected_field_name, fields = :fields)
        @expected_field_name = expected_field_name.to_s
        @fields = fields.to_sym
        @expectations = []
        @descriptions = []
      end

      def matches?(graph_object)
        @graph_object = graph_object

        @actual_field = field_collection[@expected_field_name]
        return false if @actual_field.nil?

        @results = @expectations.map do |expectaiton|
          name, expected_value = expectaiton
          [name, send("#{name}_matches?", expected_value)]
        end.to_h
        @results.values.all?
      end

      def that_returns(expected_field_type)
        @expectations << [:type, expected_field_type]
        @descriptions << "of type `#{expected_field_type}`"

        self
      end
      alias returning that_returns
      alias of_type that_returns

      def with_property(expected_property_name)
        @expectations << [:property, expected_property_name.to_s]
        @descriptions << "reading from the `#{expected_property_name}` property"

        self
      end

      def with_hash_key(expected_hash_key)
        @expectations << [:hash_key, expected_hash_key.to_s]
        @descriptions << "reading from the `#{expected_hash_key}` hash_key"

        self
      end

      def with_metadata(expected_metadata)
        @expectations << [:metadata, expected_metadata]
        @descriptions << "with metadata `#{expected_metadata.inspect}`"

        self
      end

      def failure_message
        "expected #{describe_obj(@graph_object)} to " \
          "#{description}, #{explanation}."
      end

      def description
        ["define field `#{@expected_field_name}`"].concat(@descriptions).join(', ')
      end

      private

      def explanation
        return 'but no field was found with that name' unless @actual_field
        @results.each do |result|
          name, match = result
          return send("#{name}_explanation") unless match
        end
      end

      def type_matches?(expected_field_type)
        raise method_missing_error(:type) unless @actual_field.respond_to?(:type)
        types_match?(@actual_field.type, expected_field_type)
      end

      def property_matches?(expected_property_name)
        raise method_missing_error(:property) unless @actual_field.respond_to?(:property)
        @actual_field.property.to_s == expected_property_name
      end

      def hash_key_matches?(expected_hash_key)
        raise method_missing_error(:hash_key) unless @actual_field.respond_to?(:hash_key)
        @actual_field.hash_key.to_s == expected_hash_key
      end

      def metadata_matches?(expected_metadata)
        @actual_field.metadata == expected_metadata
      end

      def type_explanation
        "but the field type was `#{@actual_field.type}`"
      end

      def property_explanation
        "but the property was `#{@actual_field.property}`"
      end

      def hash_key_explanation
        "but the hash_key was `#{@actual_field.hash_key}`"
      end

      def metadata_explanation
        "but the metadata was `#{@actual_field.metadata.inspect}`"
      end

      def method_missing_error(method_name)
        "The `#{@expected_field_name}` field defined by the GraphQL " \
          "object does\'t seem valid as it does not respond to ##{method_name}. " \
          "\n\n\tThe field found was #{@actual_field.inspect}. "
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
        case @fields
        when :fields        then 'have_a_field'
        when :input_fields  then 'have_an_input_field'
        when :return_fields then 'have_a_return_field'
        end
      end
    end
  end
end
