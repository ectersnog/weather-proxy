# frozen_string_literal: true

module Schemas
  module Weather
    def self.schema
      {
        weather_current_response: {
          type: :object,
          properties: {
            current: {
              type: :object,
              properties: {
                temperature: { type: :integer },
                rain_chance: {
                  type: :object,
                  properties: {
                    unitCode: { type: :string },
                    value: { type: :integer }
                  }
                },
                wind_speed: { type: :string },
                wind_direction: { type: :string },
                short_forecast: { type: :string },
                detailed_forecast: { type: :string }
              }
            }
          }
        },
        weather_error_response: {
          oneOf: [
            {
              type: :object,
              properties: {
                errors: { type: :string }
              }
            },
            {
              type: :object,
              properties: {
                errors: {
                  type: :array,
                  items: {
                    type: :string
                  }
                }
              }
            }
          ]
        }
      }
    end
  end
end
