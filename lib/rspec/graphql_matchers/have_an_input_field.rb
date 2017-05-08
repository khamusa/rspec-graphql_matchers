module RSpec
  module GraphqlMatchers
    class HaveAnInputField < HaveAField

      def matches?(graph_object)
        @graph_object = graph_object

        unless @graph_object.respond_to?(:input_fields)
          raise "Invalid object #{@graph_object} provided to have_an_input_field " \
            'matcher. It does not seem to be a valid GraphQL object type.'
        end

        @actual_field = @graph_object.input_fields[@expected_field_name]
        valid_field? && types_match?(@actual_field.type, @expected_field_type)
      end

    end
  end
end