# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe "v1/weather" do
  context "when weather service is available" do
    before do
      allow(Weather::Current).to receive(:call).and_return(
        WeatherResult.new(
          success?: true,
          success: {
            temperature: 78,
            rain_chance: {
              unitCode: 'wmoUnit:percent',
              value: 20
            },
            wind_speed: '10 mph',
            wind_direction: 'SW',
            short_forecast: 'Sunny',
            detailed_forecast: 'A sunny day with a high of 78 degrees and small chance of rain.'
          }
        )
      )
    end

    path '/v1/weather' do
      get('current weather') do
        parameter name: :q, in: :query, type: :string

        response '200', 'current weather by city' do
          schema "$ref" => '#/components/schemas/weather_current_response'
          let(:q) { 'Tulsa' }

          run_test!
        end
      end
    end
  end

  context "when weather service is unavailable" do
    before do
      allow(Weather::Current).to receive(:call).and_return(
        WeatherResult.new(
          success?: false,
          failure: 'Location not found'
        )
      )
    end

    path '/v1/weather' do
      get('current weather') do
        parameter name: :q, in: :query, type: :string

        response '404', 'service unavailable' do
          schema "$ref" => '#/components/schemas/weather_error_response'
          let(:q) { 'Tulsa' }

          run_test!
        end
      end
    end
  end
end
