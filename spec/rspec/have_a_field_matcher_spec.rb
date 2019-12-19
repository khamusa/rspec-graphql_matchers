# frozen_string_literal: true

require 'spec_helper'

module RSpec::GraphqlMatchers
  describe 'expect(a_type).to have_a_field(field_name)' do
    shared_examples 'have a field' do
      it { is_expected.to have_a_field(:id) }

      it 'passes when the type defines the field' do
        expect(a_type).to have_a_field(:id)
      end

      it 'passes with the underscored field name' do
        expect(a_type).to have_a_field(:is_test)
      end

      it 'passes with the camel cased field name' do
        expect(a_type).to have_a_field(:isTest)
      end

      it 'fails when the type does not define the expected field' do
        expect { expect(a_type).to have_a_field(:ids) }
          .to fail_with(
            'expected TestObject to define field `ids` but no field was found ' \
            'with that name'
          )
      end

      it 'fails with a failure message when the type does not define the field' do
        expect { expect(a_type).to have_a_field(:ids) }
          .to fail_with(
            'expected TestObject to define field `ids` but no field ' \
            'was found with that name'
          )
      end

      it 'provides a description' do
        matcher = have_a_field(:id)
        matcher.matches?(a_type)

        expect(matcher.description).to eq('define field `id`')
      end

      describe '.that_returns(a_type)' do
        it 'passes when the type defines the field with correct type as ' \
          'strings' do
          expect(a_type).to have_a_field(:id).that_returns('ID!')
          expect(a_type).to have_a_field('other').that_returns('String')
          expect(a_type).to have_a_field(:is_test).of_type('Boolean')
          expect(a_type).to have_a_field(:isTest).of_type('Boolean')
        end

        it 'passes when the type defines the field with correct type as ' \
          'graphql objects' do
          expect(a_type).to have_a_field(:id).that_returns('ID!')
          expect(a_type).to have_a_field('other').of_type(types.String)
          expect(a_type).to have_a_field(:is_test).of_type(types.Boolean)
          expect(a_type).to have_a_field(:isTest).of_type(types.Boolean)
        end

        it 'fails when the type defines a field of the wrong type' do
          expect { expect(a_type).to have_a_field(:id).returning('ID') }
            .to fail_with(
              'expected TestObject to define field `id` ' \
              'of type `ID`, but it was `ID!`'
            )

          expect { expect(a_type).to have_a_field('other').returning(!types.Int) }
            .to fail_with(
              'expected TestObject to define field `other` ' \
              'of type `Int!`, but it was `String`'
            )
        end

        context 'when an invalid type is passed' do
          let(:a_type) { {} }

          it 'fails with a Runtime error' do
            expect { expect(a_type).to have_a_field(:id) }
              .to raise_error(
                RuntimeError,
                'Invalid object {} provided to have_a_field ' \
                'matcher. It does not seem to be a valid GraphQL object type.'
              )
          end
        end
      end

      describe '.with_hash_key(hash_key)' do
        it { is_expected.to have_a_field(:other).with_hash_key(:other_on_hash) }
        it { is_expected.to have_a_field(:other).with_hash_key('other_on_hash') }

        it 'fails when the hash_key is incorrect' do
          expect do
            expect(a_type).to have_a_field(:other).with_hash_key(:whatever)
          end.to fail_with(
            'expected TestObject to define field `other` ' \
            'with hash key `whatever`, but it was `other_on_hash`'
          )
        end
      end
    end

    context 'using the new class-based api' do
      subject(:a_type) do
        Class.new(GraphQL::Schema::Object) do
          graphql_name 'TestObject'

          field :id, types.ID, null: false
          field :other, types.String, hash_key: :other_on_hash, null: true
          field :is_test, types.Boolean, null: true
        end
      end

      include_examples 'have a field'

      context 'with fields defined by implementing an interface' do
        subject(:a_type) do
          actual_interface = Module.new do
            include GraphQL::Schema::Interface
            graphql_name 'ActualInterface'

            field :other, types.String, hash_key: :other_on_hash, null: true
            field :is_test, types.Boolean, null: true
          end

          Class.new(GraphQL::Schema::Object) do
            graphql_name 'TestObject'

            implements actual_interface
            implements GraphQL::Relay::Node.interface
          end
        end

        include_examples 'have a field'
      end
    end

    context 'with legacy DSL api' do
      subject(:a_type) do
        GraphQL::ObjectType.define do
          name 'TestObject'

          field :id,
                !types.ID,
                property: :id_on_model,
                foo: true,
                bar: { nested: { objects: true, arrays: [1, 2, 3] } }

          field :other,
                types.String,
                hash_key: :other_on_hash

          field :isTest, types.Boolean
        end
      end

      before do
        GraphQL::Field.accepts_definitions(
          foo: GraphQL::Define.assign_metadata_key(:foo),
          bar: GraphQL::Define.assign_metadata_key(:bar)
        )
      end

      include_examples 'have a field'

      describe '.with_property(property_name)' do
        it { is_expected.to have_a_field(:id).with_property(:id_on_model) }
        it { is_expected.to have_a_field(:id).with_property('id_on_model') }

        it 'fails when the property is incorrect' do
          expect { expect(a_type).to have_a_field(:id).with_property(:whatever) }
            .to fail_with(
              'expected TestObject to define field `id`' \
              ' resolving with property `whatever`,' \
              ' but it was `id_on_model`'
            )
        end
      end

      describe '.with_metadata(metadata)' do
        it do
          expected = {
            foo: true,
            bar: { nested: { objects: true, arrays: [1, 2, 3] } }
          }
          is_expected.to have_a_field(:id).with_metadata(expected)
        end

        it 'matches when the object keys are not in the same order' do
          expected = {
            bar: { nested: { arrays: [1, 2, 3], objects: true } },
            foo: true
          }
          is_expected.to have_a_field(:id).with_metadata(expected)
        end

        it 'fails when the metadata is incorrect' do
          expected = {
            foo: false,
            bar: { nested: { objects: false, arrays: [2, 3, 1] } }
          }
          expect { expect(a_type).to have_a_field(:id).with_metadata(expected) }
            .to fail_with(
              'expected TestObject to define field `id`' \
              " with metadata `#{expected.inspect}`, but it was" \
              ' `{:foo=>true, :bar=>{:nested=>{:objects=>true, :arrays=>[1, 2, 3]}}}`'
            )
        end
      end
    end
  end
end
