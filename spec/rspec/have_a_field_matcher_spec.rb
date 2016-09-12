require 'spec_helper'
require 'graphql'

module RSpec::GraphqlMatchers
  describe 'expect(a_type).to have_a_field(field_name).that_returns(a_type)' do
    subject(:a_type) { double(:type, fields: type_fields) }
    let(:type_fields) { { 'id' => double(:field, type: types.String) } }

    it { is_expected.to have_a_field(:id) }

    it 'passes when the type defines the field' do
      expect(a_type).to have_a_field(:id)
    end

    it 'fails when the type does not define the expected field' do
      expect(a_type).not_to have_a_field(:ids)
    end

    it 'fails with a failure message when the type does not define the field' do
      expect { expect(a_type).to have_a_field(:ids) }
        .to fail_with("expected #{a_type.inspect} to define field `ids`")
    end

    it 'provides a description' do
      matcher = have_a_field(:id)
      matcher.matches?(a_type)

      expect(matcher.description).to eq('define field `id`')
    end

    it 'passes when the type defines the field with correct type' do
      expect(a_type).to have_a_field(:id).that_returns('String')
    end

    it 'fails when the type defines a field of the wrong type' do
      expect { expect(a_type).to have_a_field(:id).returning('String!') }
        .to fail_with(
          "expected #{a_type.inspect} to define field `id` of type `String!`"
        )
    end
  end
end
