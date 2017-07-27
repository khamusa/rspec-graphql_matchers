require 'spec_helper'

describe 'expect(a_field).to accept_arguments(arg_name: arg_type, ...)' do
  subject(:field) do
    double(
      :field,
      arguments: actual_args
    )
  end

  let(:actual_args) { {} }

  it 'can also be used in singular form' do
    expect do
      expect(field).to accept_argument(actual_args)
    end.not_to raise_error
  end

  describe '#matches?' do
    context 'when expecting a single argument with type' do
      let(:expected_args) { { id: types.String } }

      context 'when the field accepts the expected argument name and type' do
        let(:actual_args) { { 'id' => double(:field, type: types.String) } }

        it { is_expected.to accept_arguments(expected_args) }
      end

      context 'when the field also accepts the expected argument name and ' \
              'type' do
        let(:actual_args) do
          {
            'name' => double(:field, type: types.Int),
            'id' => double(:field, type: types.String),
            'description' => double(:field, type: types.Float)
          }
        end

        it { is_expected.to accept_arguments(expected_args) }
      end

      context 'the field accepts an argument with the same name but ' \
              'different type' do
        let(:actual_args) { { 'id' => double(:field, type: types.Int) } }

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'the field accepts no arguments' do
        let(:actual_args) { {} }

        it { is_expected.not_to accept_arguments(expected_args) }
      end
    end

    context 'when expecting multiple arguments with type' do
      let(:expected_args) do
        {
          id: types.String,
          name: types.String,
          precision: types.Float,
          public: types.Boolean
        }
      end

      context 'when the field accepts only one argument with correct name ' \
              'and type' do
        let(:actual_args) { { 'id' => double(:field, type: types.String) } }

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'when the field accepts all but one of the argument expected ' \
              'args' do
        let(:actual_args) do
          {
            'name' => double(:field, type: types.String),
            'id' => double(:field, type: types.String),
            'public' => double(:field, type: types.Boolean)
          }
        end

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'when the field accepts all arguments with correct type' do
        let(:actual_args) do
          {
            'name' => double(:field, type: types.String),
            'id' => double(:field, type: types.String),
            'public' => double(:field, type: types.Boolean),
            'precision' => double(:field, type: types.Float)
          }
        end

        it { is_expected.to accept_arguments(expected_args) }
      end

      context 'when the field accepts all arguments, but one has the wrong ' \
              'type' do
        let(:actual_args) do
          {
            'name' => double(:field, type: types.String),
            'id' => double(:field, type: !types.String),
            'public' => double(:field, type: types.Boolean),
            'precision' => double(:field, type: types.Float)
          }
        end

        it { is_expected.not_to accept_arguments(expected_args) }
      end

      context 'the field accepts no arguments' do
        let(:actual_args) { {} }

        it { is_expected.not_to accept_arguments(expected_args) }
      end
    end
  end

  describe '#description' do
    let(:matcher) { accept_arguments(expected_args) }

    subject(:description) do
      matcher.matches?(field)
      matcher.description
    end

    context 'with a single expected argument with types specified' do
      let(:expected_args) { { ability: types.Float } }

      it 'returns a description with the argument name and type' do
        expect(description)
          .to eq('accept arguments ability(Float)')
      end
    end

    context 'with multiple expected arguments with types specified' do
      let(:expected_args) do
        { ability: types.Int, id: types.Int, some: types.Boolean }
      end

      it 'describes the arguments the field should accept and their types' do
        expect(description)
          .to eq('accept arguments ability(Int), id(Int), some(Boolean)')
      end
    end
  end

  describe '#failure_message' do
    let(:matcher) { accept_arguments(expected_args) }
    let(:expected_args) { { will: 'NotMatch' } }

    subject(:failure_message) do
      matcher.matches?(field)
      matcher.failure_message
    end

    it 'informs the expected and actual types' do
      expect(failure_message).to end_with(
        'to accept arguments will(NotMatch)'
      )
    end

    context 'the field does not respond to #name' do
      it 'describes the field through #inspect' do
        expect(failure_message).to start_with(
          "expected field '#{field.inspect}' to"
        )
      end
    end

    context 'the field responds to #name' do
      before { allow(field).to receive(:name).and_return('AField') }

      it 'describes the field through #name' do
        expect(failure_message)
          .to start_with("expected field 'AField' to")
      end
    end
  end
end
