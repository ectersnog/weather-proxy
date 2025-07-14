# frozen_string_literal: true

module Weather
  class Current < ApplicationOperation
    Location = Data.define(:lat, :lon)
    Station = Data.define(:office, :grid_location_x, :grid_location_y)
    Forecast = Data.define(
      :temperature,
      :rain_chance,
      :wind_speed,
      :wind_direction,
      :short_forecast,
      :detailed_forecast,
      :endtime
    )

    def self.call(query)
      new.call(query)
    end

    def call(query)
      station = step find_location(query)
      location = step find_station(station)
      step find_forecast(location)
    end

    private

    def find_location(query)
      geodata = Rails.cache.fetch(cache_key("l", query)) do
        response = Geodata.find(query)
        return Failure() if response.nil?

        Location.new(
          lat: response[:lat],
          lon: response[:lon]
        )
      end
      Success(geodata)
    end

    def find_station(station)
      station = Rails.cache.fetch(cache_key("s", station)) do
        response = ExternalData.station(station)
        return Failure() if response.nil?

        Station.new(
          office: response[:office],
          grid_location_x: response[:grid_location_x],
          grid_location_y: response[:grid_location_y]
        )
      end
      Success(station)
    end

    def find_forecast(location)
      key = cache_key("f", "#{location.office}:#{location.grid_location_x}:#{location.grid_location_y}")
      return Rails.cache.fetch(key) if Rails.cache.exist?(key)

      response = ExternalData.forecast(location)
      return Failure() if response.nil?

      forecast = Forecast.new(
        temperature: response[:temperature],
        rain_chance: response[:rain_chance],
        wind_speed: response[:wind_speed],
        wind_direction: response[:wind_direction],
        short_forecast: response[:short_forecast],
        detailed_forecast: response[:detailed_forecast],
        endtime: response[:endtime]
      )
      Rails.cache.write(key, forecast, expires_at: Time.iso8601(forecast.endtime))

      Success(forecast)
    end

    def cache_key(type, query)
      "#{type}:#{query}"
    end
  end
end
