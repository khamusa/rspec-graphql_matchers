require 'spec_helper'

module RSpec::GraphqlMatchers
  describe 'expect(a_type).to have_a_field(field_name)' do
    shared_examples 'have a field' do
      it { is_expected.to have_a_field(:id) }

      it 'passes when the type defines the field' do
        expect(a_type).to have_a_field(:id)
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
            "expected TestObject to define field `ids` but no field " \
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
          expect(a_type).to have_a_field(:id).that_returns('String')
          expect(a_type).to have_a_field('other').that_returns('ID!')
        end

        it 'passes when the type defines the field with correct type as ' \
          'graphql objects' do
          expect(a_type).to have_a_field(:id).that_returns(types.String)
          expect(a_type).to have_a_field('other').of_type('ID!')
        end

        it 'fails when the type defines a field of the wrong type' do
          expect { expect(a_type).to have_a_field(:id).returning('String!') }
            .to fail_with(
              "expected TestObject to define field `id` " \
              'of type `String!`, but it was `String`'
            )

          expect { expect(a_type).to have_a_field('other').returning(!types.Int) }
            .to fail_with(
              "expected TestObject to define field `other` " \
              'of type `Int!`, but it was `ID!`'
            )
        end

        context 'when an invalid type is passed' do
          let(:a_type) { Hash.new }

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
            "expected TestObject to define field `other` " \
            'with hash key `whatever`, but it was `other_on_hash`'
          )
        end
      end
    end

    context 'using the new class-based api' do
      subject(:a_type) do
        Class.new(GraphQL::Schema::Object) do
          graphql_name 'TestObject'

          field :id, types.String, null: true

          field :other, types.ID, hash_key: :other_on_hash, null: false
        end
      end

      include_examples 'have a field'
    end

    context 'with legacy DSL api' do
      subject(:a_type) do
        GraphQL::ObjectType.define do
          name 'TestObject'

          field :id,
            types.String,
            property: :id_on_model,
            foo: true,
            bar: { nested: { objects: true, arrays: [1, 2, 3] } }

          field :other,
            !types.ID,
            hash_key: :other_on_hash
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
              "expected TestObject to define field `id`" \
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

        it 'fais when the metadata is incorrect' do
          actual = a_type.fields['id'].metadata
          expected = {
            foo: false,
            bar: { nested: { objects: false, arrays: [2, 3, 1] } }
          }
          expect { expect(a_type).to have_a_field(:id).with_metadata(expected) }
            .to fail_with(
              "expected TestObject to define field `id`" \
              " with metadata `#{expected.inspect}`, but it was" \
              " `{:foo=>true, :bar=>{:nested=>{:objects=>true, :arrays=>[1, 2, 3]}}}`"
            )
        end
      end
    end
  end
end
