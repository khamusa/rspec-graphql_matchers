# frozen_string_literal: true

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
          @actual_hash_key = get_hash_key(actual_field)
          @actual_hash_key == @expected_hash_key.to_sym
        end

        def failure_message
          "#{description}, but it was `#{@actual_hash_key}`"
        end

        private

        def get_hash_key(actual_field)
          if actual_field.respond_to?(:hash_key)
            return actual_field.hash_key.to_sym if actual_field.hash_key
          end

          if actual_field.respond_to?(:metadata)
            return actual_field.metadata[:type_class].method_sym
          end

          actual_field.method_sym
        end
      end
    end
  end
end
