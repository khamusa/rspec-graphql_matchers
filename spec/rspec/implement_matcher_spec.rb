require 'spec_helper'

module RSpec::GraphqlMatchers
  describe 'expect(a_type).to implement(interface_names)' do
    AnInterface = GraphQL::InterfaceType.define do
      name 'AnInterface'
    end

    AnotherInterface = GraphQL::InterfaceType.define do
      name 'AnotherInterface'
    end

    subject(:a_type) do
      GraphQL::ObjectType.define do
        name 'TestObject'
        interfaces [
          GraphQL::Relay::Node.interface,
          AnInterface
        ]
      end
    end

    it { is_expected.to implement('Node') }
    it { is_expected.to implement('AnInterface') }
    it { is_expected.to implement('Node', 'AnInterface') }
    it { is_expected.to implement(['Node']) }
    it { is_expected.to implement(['AnInterface']) }
    it { is_expected.to implement(['Node', 'AnInterface']) }
    it { is_expected.to implement(GraphQL::Relay::Node.interface, AnInterface) }
    it { is_expected.to implement([GraphQL::Relay::Node.interface, AnInterface]) }

    it { is_expected.not_to implement('AnotherInterface') }
    it { is_expected.not_to implement(['AnotherInterface']) }
    it { is_expected.not_to implement(AnotherInterface) }
    it { is_expected.not_to implement([AnotherInterface]) }

    it 'fails with a failure message when the type does include the interfaces' do
      expect { expect(a_type).to implement('AnotherInterface') }
        .to fail_with(
          "expected interfaces: AnotherInterface\n" \
          'actual interfaces:   Node, AnInterface'
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
