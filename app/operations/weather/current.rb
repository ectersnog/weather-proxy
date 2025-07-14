# frozen_string_literal: true

module Weather
  class Current < ApplicationOperation
    def call(params:)
      search_type = step find_search_type(params:)
      if search_type == :zip
        lat_lon = step find_loc_by_zip(params:)
      elsif search_type == :query
        lat_lon = step find_loc_by_query(params:)
      else
        return :invalid_query
      end
      station = step find_station(lat_lon:)
      step find_weather(station)
    end

    private

    def find_search_type(params:)
      return Failure(:invalid_query) if params[:q].blank?

      params[:q] = params[:q].strip
      if params[:q].match?(/^\d{5}$/) # ZIP code format
        Success(:zip)
      else
        Success(:query)
      end
    end

    def find_loc_by_zip(params:)
      geodata = Geodata.find_by(params[:q])
      return Failure(:no_loc) if geodata == :not_found

      Success(geodata)
    end

    def find_loc_by_query(params:)
      geodata = Geodata.find_by(params[:q])
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

      Rails.logger.info "Fetching weather data for office: #{office}, gridX: #{grid_location_x}, gridY: #{grid_location_y}"
      weather = HTTP.get("https://api.weather.gov/gridpoints/#{office}/#{grid_location_x},#{grid_location_y}/forecast")

      if weather.status.success?
        forecast = weather.parse(:json)["properties"]["periods"]
        weather_info = forecast.first
        current_weather = {
          temperature: weather_info["temperature"],
          rain_chance: weather_info["probabilityOfPrecipitation"],
          wind_speed: weather_info["windSpeed"],
          wind_direction: weather_info["windDirection"],
          short_forecast: weather_info["shortForecast"],
          detailed_forecast: weather_info["detailedForecast"],
          endtime: weather_info["endTime"]
        }
        expire_time = Time.zone.parse(current_weather[:endtime])
        Rails.cache.write(cache_name, current_weather, expires_at: expire_time)
        Success(Rails.cache.fetch(cache_name))
      else
        Failure(weather.errors.full_messages)
      end
    end
  end
end
