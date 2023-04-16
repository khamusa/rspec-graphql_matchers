# frozen_string_literal: true

require 'spec_helper'

module RSpec
  module GraphqlMatchers
    describe 'expect(a_type).to have_a_return_field(field_name)' \
             '.that_returns(a_type)' do
      subject(:a_type) do
        Class.new(GraphQL::Schema::RelayClassicMutation) do
          graphql_name 'TestObject'

          field :id, GraphQL::Types::String
          field :other, GraphQL::Types::ID, null: false
        end
      end

      it { is_expected.to have_a_return_field(:id) }

      it 'passes when the type defines the field' do
        expect(a_type).to have_a_return_field(:id)
      end

      it 'fails when the type does not define the expected field' do
        expect(a_type).not_to have_a_return_field(:ids)
      end

      it 'fails with a failure message when the type does not define the field' do
        expect { expect(a_type).to have_a_return_field(:ids) }
          .to fail_with(
            "expected #{a_type.graphql_name} to define field `ids` but no field was " \
            'found with that name'
          )
      end

      it 'provides a description' do
        matcher = have_a_return_field(:id)
        matcher.matches?(a_type)

        expect(matcher.description).to eq('define field `id`')
      end

      it 'passes when the type defines the field with correct type as strings' do
        expect(a_type).to have_a_return_field(:id).that_returns('String')
        expect(a_type).to have_a_return_field('other').that_returns('ID!')
      end

      it 'passes when the type defines the field with correct type as graphql ' \
         'objects' do
        expect(a_type).to have_a_return_field(:id).that_returns(GraphQL::Types::String)
        expect(a_type).to have_a_return_field('other').that_returns(GraphQL::Types::ID.to_non_null_type)
      end

      it 'fails when the type defines a field of the wrong type' do
        expect { expect(a_type).to have_a_return_field(:id).returning('String!') }
          .to fail_with(
            "expected #{a_type.graphql_name} to define field `id` of type `String!`, " \
            'but it was `String`'
          )

        expect do
          expect(a_type).to have_a_return_field('other').returning(GraphQL::Types::Int.to_non_null_type)
        end.to fail_with(
          "expected #{a_type.graphql_name} to define field `other` of type `Int!`, " \
          'but it was `ID!`'
        )
      end

      context 'when an invalid type is passed' do
        let(:a_type) { double(to_s: 'InvalidObject') }

        it 'fails with a Runtime error' do
          expect { expect(a_type).to have_a_return_field(:id) }
            .to raise_error(
              RuntimeError,
              'Invalid object InvalidObject provided to have_a_field ' \
              'matcher. It does not seem to be a valid GraphQL object type.'
            )
        end
      end
    end
  end
end
