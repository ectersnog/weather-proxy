# frozen_string_literal: true

module Weather
  class Current < ApplicationOperation
    def call(params:)
      lat_lon = step find_lat_lon(params:)
      station = step find_station(lat_lon:)
      step find_weather(station)
    end

    private

    def find_lat_lon(params:)
      if params[:zip].present?
        geodata = Geodata.find_by_zip(params[:zip].strip)
      elsif params[:city].present? && params[:state].present?
        geodata = Geodata.find_by_city(params[:city].strip, params[:state].strip)
      else
        return Failure(:no_params)
      end
      return Failure(:no_loc) if geodata == :not_found

      Success(geodata)
    end

    def find_station(lat_lon:)
      station = HTTP.get("https://api.weather.gov/points/#{lat_lon[:lat]},#{lat_lon[:lon]}")
      return Failure(:no_station) if station.blank?

      Success(station)
    end

    def find_weather(station)
      station_properties = station.parse(:json)["properties"]
      office = station_properties["cwa"]
      grid_location_x = station_properties["gridX"]
      grid_location_y = station_properties["gridY"]
      cache_name = "#{office}:#{grid_location_x},#{grid_location_y}"
      return Success(Rails.cache.fetch(cache_name)) if Rails.cache.exist?(cache_name)

      puts "Fetching weather data for office: #{office}, gridX: #{grid_location_x}, gridY: #{grid_location_y}"
      weather = HTTP.get("https://api.weather.gov/gridpoints/#{office}/#{grid_location_x},#{grid_location_y}/forecast")

      if weather.status.success?
        current_temp = weather.parse(:json)["properties"]["periods"].first["temperature"]
        Rails.cache.write("#{office}:#{grid_location_x},#{grid_location_y}", current_temp, expires_at: Time.now.end_of_day)
        Success(current_temp)
      else
        Failure(weather.errors.full_messages)
      end
    end
  end
end
