require 'spec_helper'

describe 'expect(a_field).to be_of_type(graphql_type)' do
  scalar_types = [types.Boolean, types.Int, types.Float, types.String, types.ID]
  list_types   = scalar_types.map { |t| types[t] }
  all_types    = scalar_types + scalar_types.map(&:'!') + list_types.map(&:'!')

  all_types.each do |scalar_type|
    context "when the field has type #{scalar_type}" do
      subject(:field) { double('GrahQL Field', type: field_type) }
      let(:field_type) { scalar_type }

      it "matches a graphQL type object representing #{scalar_type}" do
        expect(field).to be_of_type(scalar_type)
      end

      it "matches the string '#{scalar_type}'" do
        expect(field).to be_of_type(scalar_type.to_s)
      end

      it "does not match the string '#{scalar_type.to_s.downcase}'" do
        expect(field).not_to be_of_type(scalar_type.to_s.downcase)
      end

      scalar_types.each do |another_scalar|
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
                "to be of type '#{expected_type}', but it was '#{field.type}'")
            end

            context 'the field does not respond to #name' do
              it 'describes the field through #inspect' do
                expect(failure_message).to start_with(
                  "expected field '#{field.inspect}' to be of type")
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

    it %q{is "be of type 'String'"} do
      matcher.matches?(double(type: 'NotMeaningful'))
      expect(matcher.description).to eq("be of type 'String'")
    end
  end
end
