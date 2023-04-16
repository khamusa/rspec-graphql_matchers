# frozen_string_literal: true

require 'spec_helper'
require 'graphql'

describe 'expect(a_field).to accept_arguments(arg_name: arg_type, ...)' do
  subject(:field) do
    Class.new(GraphQL::Schema::InputObject) do
      graphql_name 'SomeInputObject'

      argument :id, GraphQL::Types::ID, required: true
      argument :name, GraphQL::Types::String, required: true
      argument :age, GraphQL::Types::Int, required: false
      argument :is_test, GraphQL::Types::Boolean, required: false
      argument :not_camelized, GraphQL::Types::Boolean, required: false, camelize: false
    end
  end

  describe '#matches?' do
    context 'when expecting a single argument with type' do
      let(:expected_args) { { id: GraphQL::Types::ID.to_non_null_type } }

      context 'when the field accepts the expected argument name and type' do
        it { is_expected.to accept_arguments(expected_args) }
      end

      context 'the field accepts an argument with the same name but different type' do
        let(:expected_args) { { id: GraphQL::Types::ID } }

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'the field does not accept the expected args' do
        let(:expected_args) { { idz: GraphQL::Types::ID.to_non_null_type } }

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'when the expected argument is camelcase' do
        let(:expected_args) { { isTest: GraphQL::Types::Boolean } }

        it { is_expected.to accept_arguments(expected_args) }
      end

      context 'when the expected argument is underscored' do
        let(:expected_args) { { is_test: GraphQL::Types::Boolean } }

        it { is_expected.to accept_arguments(expected_args) }

        context 'when the actual argument is not camelized' do
          let(:expected_args) { { not_camelized: GraphQL::Types::Boolean } }

          it { is_expected.to accept_arguments(expected_args) }
        end
      end
    end

    context 'when expecting multiple arguments with type' do
      context 'when the field accepts only one argument with correct name and type' do
        let(:expected_args) do
          {
            id: GraphQL::Types::ID.to_non_null_type,
            age: GraphQL::Types::Int.to_list_type,
            name: GraphQL::Types::String
          }
        end

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'when the field accepts all but one of the argument expected args' do
        let(:expected_args) do
          {
            id: GraphQL::Types::ID.to_non_null_type,
            age: GraphQL::Types::Int,
            name: GraphQL::Types::Float.to_non_null_type
          }
        end

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'when the field accepts all arguments with correct type' do
        let(:expected_args) do
          {
            id: GraphQL::Types::ID.to_non_null_type,
            age: GraphQL::Types::Int,
            name: GraphQL::Types::String.to_non_null_type
          }
        end

        it { is_expected.to accept_arguments(expected_args) }
      end
    end
  end

  describe '#description' do
    let(:matcher) { accept_arguments(expected_args) }

    subject(:description) do
      matcher.matches?(field)
      matcher.description
    end

    context 'with a single expected argument with types specified' do
      let(:expected_args) { { ability: 'Float' } }

      it 'returns a description with the argument name and type' do
        expect(description)
          .to eq('accept arguments ability(Float)')
      end
    end

    context 'with multiple expected arguments with types specified' do
      let(:expected_args) do
        { ability: GraphQL::Types::Int, id: GraphQL::Types::Int, some: GraphQL::Types::Boolean }
      end

      it 'describes the arguments the field should accept and their types' do
        expect(description)
          .to eq('accept arguments ability(Int), id(Int), some(Boolean)')
      end
    end
  end

  describe '#failure_message' do
    let(:matcher) { accept_arguments(expected_args) }
    let(:expected_args) { { will: 'NotMatch' } }

    subject(:failure_message) do
      matcher.matches?(field)
      matcher.failure_message
    end

    it 'informs the expected and actual types' do
      expect(failure_message).to end_with(
        'to accept arguments will(NotMatch)'
      )
    end

    it 'describes the field through #name' do
      expect(failure_message)
        .to start_with("expected field 'SomeInputObject' to")
    end
  end
end
