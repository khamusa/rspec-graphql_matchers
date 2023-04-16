# frozen_string_literal: true

module RSpec
  module GraphqlMatchers
    module HaveAFieldMatchers
      class OfType < RSpec::GraphqlMatchers::BeOfType
        def description
          "of type `#{type_name(expected)}`"
        end

        def failure_message
          "#{description}, but it was `#{type_name(sample.type)}`"
        end
      end
    end
  end
end
