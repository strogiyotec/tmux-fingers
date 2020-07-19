require 'spec_helper'

describe Fingers::MatchFormatter do
  let(:highlight_format) { '%s' }
  let(:hint_format) { '[%s]' }
  let(:hint_position) { 'left' }
  let(:selected_hint_format) { '{%s}' }
  let(:selected_highlight_format) { '{%s}' }
  let(:compact) { false }
  let(:selected) { false }

  let(:hint) { 'a' }
  let(:highlight) { 'yolo' }

  let(:formatter) {
    described_class.new(
      highlight_format: highlight_format,
      hint_format: hint_format,
      selected_highlight_format: selected_highlight_format,
      selected_hint_format: selected_hint_format,
      hint_position: hint_position,
      compact: compact,
    )
  }

  let(:result) {
    formatter.format(hint: hint, highlight: highlight, selected: selected)
  }

  context 'when hint position' do
    context 'is set to left' do
      let(:hint_position) { 'left' }

      it 'places the hint on the left side' do
        expect(result).to eq('[a]yolo')
      end
    end

    context 'is set to right' do
      let(:hint_position) { 'right' }

      it 'places the hint on the right side' do
        expect(result).to eq('yolo[a]')
      end
    end
  end

  context 'when compact mode is set' do
    let(:compact) { true }
    let(:hint_format) { '%s' }

    context 'and position is set to left' do
      let(:hint_position) { 'left' }

      it 'correctly places the hint inside the highlight' do
        expect(result).to eq('aolo')
      end
    end

    context 'and position is set to right' do
      let(:hint_position) { 'right' }

      it 'correctly places the hint inside the highlight' do
        expect(result).to eq('yola')
      end
    end

    # TODO what if hint is longer than highlight? hehehe
  end

  context 'when a hint is selected' do
    let(:selected) { true }

    it 'selects the correct format' do
      expect(result).to eq('{a}{yolo}')
    end
  end
end

