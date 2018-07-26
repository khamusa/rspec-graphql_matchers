module RSpec
  module GraphqlMatchers
    class BaseMatcher
      private

      def types_match?(actual_type, expected_type)
        expected_type.nil? || expected_type.to_s == actual_type.to_s
      end

      def camelize(string, uppercase_first_letter = false)
        if uppercase_first_letter
          string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        else
          string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
        end
        string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
      end
    end
  end
end
