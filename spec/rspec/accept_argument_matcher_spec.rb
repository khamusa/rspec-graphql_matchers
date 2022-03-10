# frozen_string_literal: true

require 'spec_helper'

module RSpec
  module GraphqlMatchers
    describe 'expect(a_type).to accept_argument(field_name)' do
      shared_examples 'accept argument' do
        it { is_expected.to accept_argument(:id) }

        it 'passes when the type defines the field' do
          expect(a_type).to accept_argument(:id)
        end

        it 'passes with the underscored argument name' do
          expect(a_type).to accept_argument(:is_test)
        end

        it 'passes with the camel cased argument name' do
          expect(a_type).to accept_argument(:isTest)
        end

        it 'matches a non camelized argument with the underscored argument name' do
          expect(a_type).to accept_argument(:not_camelized)
        end

        it 'fails when the type does not define the expected field' do
          expect { expect(a_type).to accept_argument(:ids) }
            .to fail_with(
              'expected TestObject to accept argument `ids` but no argument was found ' \
              'with that name'
            )
        end

        it 'fails with a failure message when the type does not define the field' do
          expect { expect(a_type).to accept_argument(:ids) }
            .to fail_with(
              'expected TestObject to accept argument `ids` but no argument ' \
              'was found with that name'
            )
        end

        it 'provides a description' do
          matcher = accept_argument(:id)
          matcher.matches?(a_type)

          expect(matcher.description).to eq('accept argument `id`')
        end

        describe '.of_type(a_type)' do
          it 'passes when the type defines the field with correct type as ' \
            'strings' do
            expect(a_type).to accept_argument(:id).of_type('String')
            expect(a_type).to accept_argument('other').of_type('ID!')
            expect(a_type).to accept_argument('other' => 'ID!')
          end

          it 'passes when the type defines the field with correct type as ' \
            'graphql objects' do
            expect(a_type).to accept_argument(:id).of_type(types.String)
            expect(a_type).to accept_argument('other').of_type('ID!')
          end

          it 'fails when the type defines a field of the wrong type' do
            expect { expect(a_type).to accept_argument(:id).of_type('String!') }
              .to fail_with(
                'expected TestObject to accept argument `id` ' \
                'of type `String!`, but it was `String`'
              )

            expect { expect(a_type).to accept_argument('other').of_type(!types.Int) }
              .to fail_with(
                'expected TestObject to accept argument `other` ' \
                'of type `Int!`, but it was `ID!`'
              )

            expect { expect(a_type).to accept_argument('other' => !types.Int) }
              .to fail_with(
                'expected TestObject to accept argument `other` ' \
                'of type `Int!`, but it was `ID!`'
              )
          end

          context 'when an invalid type is passed' do
            let(:a_type) { {} }

            it 'fails with a Runtime error' do
              expect { expect(a_type).to accept_argument(:id) }
                .to raise_error(
                  RuntimeError,
                  'Invalid object {} provided to accept_argument ' \
                  'matcher. It does not seem to be a valid GraphQL object type.'
                )
            end
          end
        end
      end

      context 'using the new class-based api' do
        subject(:a_type) do
          Class.new(GraphQL::Schema::InputObject) do
            graphql_name 'TestObject'

            argument :id, GraphQL::Types::String, required: false
            argument :other, GraphQL::Types::ID, required: true
            argument :is_test, GraphQL::Types::Boolean, required: false
            argument :not_camelized, GraphQL::Types::Boolean, required: false,
                                                              camelize: false
            argument :deprecated_argument, types.String, required: false,
                                                         deprecation_reason: 'deprecated'

          end
        end

        include_examples 'accept argument'

        describe '.with_deprecation_reason' do
          let(:deprecated_argument) { :deprecated_argument }

          it 'passes when the deprecation reasons match' do
            expect(a_type).to accept_argument(deprecated_argument)
              .with_deprecation_reason('deprecated')
          end
        end
      end

      context 'with legacy DSL api' do
        subject(:a_type) do
          GraphQL::InputObjectType.define do
            name 'TestObject'

            argument :id, types.String
            argument :other, !types.ID
            argument :isTest, types.Boolean
            argument :not_camelized, types.Boolean
          end
        end

        include_examples 'accept argument'
      end
    end
  end
end
