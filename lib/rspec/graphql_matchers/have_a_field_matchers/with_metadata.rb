module RSpec
  module GraphqlMatchers
    module HaveAFieldMatchers
      class WithMetadata
        def initialize(expected_metadata)
          @expected_metadata = expected_metadata
        end

        def description
          "with metadata `#{@expected_metadata}`"
        end

        def matches?(actual_field)
          @actual_metadata = actual_field.metadata
          actual_field.metadata == @expected_metadata
        end

        def failure_message
          "#{description}, but it was `#{@actual_metadata}`"
        end
      end
    end
  end
end
