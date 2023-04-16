# frozen_string_literal: true

require 'spec_helper'

describe 'expect(a_field).to be_of_type(graphql_type)' do
  scalar_types = {
    "Boolean" => GraphQL::Types::Boolean,
    "Int" => GraphQL::Types::Int,
    "Float" => GraphQL::Types::Float,
    "String" => GraphQL::Types::String,
    "ID" => GraphQL::Types::ID
  }

  non_nullable_scalar_types = scalar_types.each_with_object({}) do |(string_name, type), result|
    result["#{string_name}!"] = type.to_non_null_type
  end

  all_types = scalar_types.merge(non_nullable_scalar_types)

  all_types.each do |(graphql_name, scalar_type)|
    context "when the field has type #{graphql_name}" do
      subject(:field) { double('GrahQL Field', type: field_type) }
      let(:field_type) { scalar_type }

      it "matches a graphQL type object representing #{graphql_name}" do
        expect(field).to be_of_type(scalar_type)
      end

      it "matches the string '#{graphql_name}'" do
        expect(field).to be_of_type(graphql_name)
      end

      it "does not match the string '#{graphql_name.downcase}'" do
        expect(field).not_to be_of_type(graphql_name.downcase)
      end

      scalar_types.each do |(another_graphql_name, another_scalar)|
        next if another_scalar == scalar_type

        context "when matching against the type #{another_scalar}" do
          let(:matcher)       { be_of_type(expected_type) }
          let(:expected_type) { another_scalar }

          it 'does not match' do
            expect(matcher.matches?(field)).to be_falsy
          end

          describe 'the failure messages' do
            subject(:failure_message) { matcher.failure_message }

            before { matcher.matches?(field) }

            it 'informs the expected and actual types' do
              expect(failure_message).to end_with(
                "to be of type '#{another_graphql_name}', but it was '#{graphql_name}'"
              )
            end

            context 'the field does not respond to #name' do
              it 'describes the field through #inspect' do
                expect(failure_message).to start_with(
                  "expected field '#{field.inspect}' to be of type"
                )
              end
            end

            context 'the field responds to #name' do
              before { allow(field).to receive(:name).and_return('AField') }

              it 'describes the field through #name' do
                expect(failure_message)
                  .to start_with("expected field 'AField' to be of type")
              end
            end
          end
        end
      end
    end
  end

  describe '#description' do
    let(:matcher) { be_of_type(String) }

    it %q(is "be of type 'String'") do
      matcher.matches?(double(type: 'NotMeaningful'))
      expect(matcher.description).to eq("be of type 'String'")
    end
  end
end
