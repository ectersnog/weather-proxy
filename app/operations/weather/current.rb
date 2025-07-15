# frozen_string_literal: true

module Weather
  class Current < ApplicationOperation
    # Class to grab the current weather for a given location.
    # It uses the Geodata service to find the location based on a query,
    # then finds the corresponding weather station and retrieves the forecast.
    # @param query [String] The location query, which can be
    # @example
    #   Weather::Current.call('Tulsa, OK')
    #

    def call(query:)
      station = step find_location(query)
      location = step find_station(station)
      step find_forecast(location)
    end

    private

    def find_location(query)
      response = Geodata.find(query)
      return Failure() if response.nil?

      Success(response)
    end

    def find_station(station)
      response = WeatherData.station(station)
      return Failure() if response.nil?

      Success(response)
    end

    def find_forecast(location)
      response = WeatherData.forecast(location)
      return Failure() if response.nil?

      Success(response)
    end
  end
end
