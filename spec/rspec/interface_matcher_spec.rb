require 'spec_helper'

module RSpec::GraphqlMatchers
  describe 'expect(a_type).to interface(interface_names)' do
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

    it { is_expected.to interface('Node') }
    it { is_expected.to interface('AnInterface') }
    it { is_expected.to interface('Node', 'AnInterface') }
    it { is_expected.to interface(['Node']) }
    it { is_expected.to interface(['AnInterface']) }
    it { is_expected.to interface(['Node', 'AnInterface']) }
    it { is_expected.to interface(GraphQL::Relay::Node.interface, AnInterface) }
    it { is_expected.to interface([GraphQL::Relay::Node.interface, AnInterface]) }

    it { is_expected.not_to interface('AnotherInterface') }
    it { is_expected.not_to interface(['AnotherInterface']) }
    it { is_expected.not_to interface(AnotherInterface) }
    it { is_expected.not_to interface([AnotherInterface]) }

    it 'fails with a failure message when the type does include the interfaces' do
      expect { expect(a_type).to interface('AnotherInterface') }
        .to fail_with(
          "expected interfaces: AnotherInterface\n" \
          'actual interfaces:   Node, AnInterface'
        )
    end

    it 'provides a description' do
      matcher = interface('Node, AnInterface')
      matcher.matches?(a_type)

      expect(matcher.description).to eq('interface Node, AnInterface')
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
