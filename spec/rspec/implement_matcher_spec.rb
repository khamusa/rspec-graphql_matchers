# frozen_string_literal: true

require 'spec_helper'

module RSpec
  module GraphqlMatchers
    describe 'expect(a_type).to implement(interface_names)' do
      AnInterface = Module.new do
        include GraphQL::Schema::Interface
        graphql_name 'AnInterface'
      end

      AnotherInterface = Module.new do
        include GraphQL::Schema::Interface
        graphql_name 'AnotherInterface'
      end

      AThirdInterface = Module.new do
        include GraphQL::Schema::Interface
        graphql_name 'AClassBasedApiInterface'
      end

      subject(:a_type) do
        Class.new(GraphQL::Schema::Object) do
          graphql_name 'TestObject'

          implements GraphQL::Types::Relay::Node
          implements AnInterface
          implements AThirdInterface
        end
      end

      it { is_expected.to implement('Node') }
      it { is_expected.to implement('AnInterface') }
      it { is_expected.to implement('AClassBasedApiInterface') }
      it { is_expected.to implement('Node', 'AnInterface', 'AClassBasedApiInterface') }
      it { is_expected.to implement(['Node']) }
      it { is_expected.to implement(['AnInterface']) }
      it { is_expected.to implement(%w[Node AnInterface]) }
      it { is_expected.to implement(GraphQL::Types::Relay::Node, AnInterface) }
      it do
        is_expected.to implement([GraphQL::Types::Relay::Node, AnInterface])
      end

      it { is_expected.not_to implement('AnotherInterface') }
      it { is_expected.not_to implement(['AnotherInterface']) }
      it { is_expected.not_to implement(AnotherInterface) }
      it { is_expected.not_to implement([AnotherInterface]) }

      it 'fails with a message when the type does include the interfaces' do
        expect { expect(a_type).to implement('AnotherInterface') }
          .to fail_with(
            "expected interfaces: AnotherInterface\n" \
            'actual interfaces:   Node, AnInterface, AClassBasedApiInterface'
          )
      end

      it 'provides a description' do
        matcher = implement('Node, AnInterface')
        matcher.matches?(a_type)

        expect(matcher.description).to eq('implement Node, AnInterface')
      end

      context 'when an invalid type is passed' do
        let(:a_type) { double(to_s: 'InvalidObject') }

        it 'fails with a Runtime error' do
          expect { expect(a_type).to have_a_field(:id) }
            .to raise_error(
              RuntimeError,
              'Invalid object InvalidObject provided to have_a_field matcher. ' \
              'It does not seem to be a valid GraphQL object type.'
            )
        end
      end
    end
  end
end
