# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::Current do
  describe '#call' do
    it 'returns the current weather for a given city' do
      result = described_class.new.call(query: 'Tulsa,OK')
      expect(result.success).to be_a(Weather::Forecast)
    end
  end
end
