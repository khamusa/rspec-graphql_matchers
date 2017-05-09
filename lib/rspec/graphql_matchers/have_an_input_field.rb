module RSpec
  module GraphqlMatchers
    class HaveAnInputField < HaveAField
      def initialize(expected_field_name)
        super
        @fields = :input_fields
      end

      def matches?(graph_object)
        @graph_object = graph_object
        @actual_field = field_collection[@expected_field_name]
        valid_field? && types_match?(@actual_field.type, @expected_field_type)
      end
    end
  end
end
