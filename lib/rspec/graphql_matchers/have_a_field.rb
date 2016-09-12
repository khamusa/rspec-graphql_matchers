module RSpec
  module GraphqlMatchers
    class HaveAField
      def initialize(field_name)
        @field_name = field_name.to_s
        @field_type = @graph_object = nil
      end

      def matches?(graph_object)
        @graph_object = graph_object

        actual_field = @graph_object.fields[@field_name]
        actual_field && types_match?(@field_type, actual_field.type)
      end

      def that_returns(field_type)
        @field_type = field_type

        self
      end
      alias returning that_returns
      alias of_type that_returns

      def failure_message
        "expected #{describe_obj(@graph_object)} to #{description}"
      end

      def description
        "define field `#{@field_name}`" + of_type_description
      end

      private

      def of_type_description
        return '' unless @field_type

        " of type `#{@field_type}`"
      end

      def types_match?(expected_type, actual_type)
        !expected_type || expected_type.to_s == actual_type.to_s
      end

      def describe_obj(field)
        field.respond_to?(:name) && field.name || field.inspect
      end
    end
  end
end
