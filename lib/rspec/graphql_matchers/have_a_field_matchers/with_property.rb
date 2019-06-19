module RSpec
  module GraphqlMatchers
    module HaveAFieldMatchers
      class WithProperty
        def initialize(expected_property_name)
          @expected_property_name = expected_property_name
        end

        def description
          "resolving with property `#{@expected_property_name}`"
        end

        def matches?(actual_field)
          @actual_property = actual_field.property.to_sym
          @actual_property == @expected_property_name.to_sym
        end

        def failure_message
          "#{description}, but it was `#{@actual_property}`"
        end
      end
    end
  end
end
