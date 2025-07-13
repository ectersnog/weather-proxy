# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::Current do
  describe '#call' do
    it 'returns the current weather for a given city' do
      result = described_class.call(params: { q: 'Tulsa,OK' })
      expect(result).to be_success
    end
  end
end
