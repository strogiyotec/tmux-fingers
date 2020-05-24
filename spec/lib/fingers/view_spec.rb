require 'spec_helper'

describe Fingers::View do
  let(:hinter) do
    hinter_double = double(:hinter)

    allow(hinter_double).to receive(:render)
    allow(hinter_double).to receive(:lookup) do |hint|
      "match-for-#{hint}"
    end

    hinter_double
  end


  let(:view) {
    described_class.new(
      hinter: hinter,
      state: OpenStruct.new
    )
  }

  it 'returns results in multi mode' do
    view.process_input('toggle_multi_mode')
    view.process_input('hint:a:main')
    view.process_input('hint:b:main')

    begin
      view.process_input('toggle_multi_mode')
    rescue ::Fingers::BailOut
      expect(view.result).to eq('match-for-a match-for-b')
    end
  end

  it 'returns result in single mode' do
    begin
      view.process_input('hint:a:main')
    rescue ::Fingers::BailOut
      expect(view.result).to eq('match-for-a')
    end
  end
end
