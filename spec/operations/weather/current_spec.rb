# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::Current do
  describe '#call' do
    it 'returns the current weather for a given city' do
      result = described_class.call('Tulsa,OK')
      expect(result.success).to be_a(Weather::Current::Forecast)
    end
  end
end
