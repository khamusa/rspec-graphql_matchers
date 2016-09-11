module RSpec
  module GraphqlMatchers
    class AcceptArguments
      attr_reader :actual_field, :expected_args

      def initialize(expected_args)
        @expected_args = expected_args
      end

      def matches?(actual_field)
        @actual_field = actual_field

        @expected_args.all? do |arg_name, arg_type|
          matches_argument?(arg_name, arg_type)
        end
      end

      def failure_message
        "expected field '#{field_name(actual_field)}' to accept arguments "\
        "#{describe_arguments(expected_args)}"
      end

      def description
        "accept arguments #{describe_arguments(expected_args)}"
      end

      private

      def matches_argument?(arg_name, arg_type)
        actual_arg = actual_field.arguments[arg_name.to_s]
        actual_arg && actual_arg.type.to_s == arg_type.to_s
      end

      def describe_arguments(what_args)
        what_args.sort.map do |arg_name, arg_type|
          "#{arg_name}(#{arg_type})"
        end.join(', ')
      end

      def field_name(field)
        field.respond_to?(:name) && field.name || field.inspect
      end
    end
  end
end
