# frozen_string_literal: true

module Weather
  class Current < ApplicationOperation
    def call(params:)
      station = step find_station(params:)
      step find_weather(station)
    end

    private

    def find_station(params:)
      city = params[:city]
      state = params[:state]
      geodata = HTTP.get("https://dashboard.waterdata.usgs.gov/service/geocoder/get/location/1.0?term=#{city}&states=#{state}")
      if geodata.status.success?
        lat = geodata.parse(:json)[0]["Latitude"].truncate(2)
        lon = geodata.parse(:json)[0]["Longitude"].truncate(2)
        station = HTTP.get("https://api.weather.gov/points/#{lat},#{lon}")
        if station.status.success?
          Success(station)
        else
          Failure("Failed to find weather station for coordinates: #{lat}, #{lon}")
        end
      end
    end

    def find_weather(station)
      station_properties = station.parse(:json)["properties"]
      office = station_properties["cwa"]
      grid_location_x = station_properties["gridX"]
      grid_location_y = station_properties["gridY"]
      weather = HTTP.get("https://api.weather.gov/gridpoints/#{office}/#{grid_location_x},#{grid_location_y}/forecast")
      if weather.status.success?
        Success(weather)
      else
        Failure(weather.errors.full_messages)
      end
    end
  end
end
