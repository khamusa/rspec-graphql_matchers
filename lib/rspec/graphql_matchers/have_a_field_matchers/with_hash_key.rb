module RSpec
  module GraphqlMatchers
    module HaveAFieldMatchers
      class WithHashKey
        def initialize(expected_hash_key)
          @expected_hash_key = expected_hash_key
        end

        def description
          "with hash key `#{@expected_hash_key}`"
        end

        def matches?(actual_field)
          get_hash_key(actual_field) == @expected_hash_key.to_sym
        end

        private

        def get_hash_key(actual_field)
          if actual_field.respond_to?(:hash_key)
            return actual_field.hash_key.to_sym
          end

          # Class-based api
          actual_field.method_sym
        end
      end
    end
  end
end
