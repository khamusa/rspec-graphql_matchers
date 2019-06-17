module RSpec
  module GraphqlMatchers
    module HaveAFieldMatchers
      class OfType < RSpec::GraphqlMatchers::BeOfType
        def description
          "of type `#{expected}`"
        end
      end
    end
  end
end
