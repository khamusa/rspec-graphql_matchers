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
          actual_field.property.to_sym == @expected_property_name.to_sym
        end
      end
    end
  end
end
