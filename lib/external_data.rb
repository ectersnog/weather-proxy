# frozen_string_literal: true

class ExternalData
  # Grabs external data such as weather and geolocation information

  USGS_URL = "https://dashboard.waterdata.usgs.gov/service/geocoder/get/location/1.0?term="
  WEATHER_BASE_URL = "https://api.weather.gov/"
  STATION = "#{WEATHER_BASE_URL}points/".freeze
  FORECAST = "#{WEATHER_BASE_URL}gridpoints/".freeze

  # Grabs location data based on a query string
  # @param query [String] the query string to search for location data
  # @return [Hash] a hash containing latitude and longitude
  #   - :lat [Float] latitude of the location
  #   - :lon [Float] longitude of the location
  #
  # @example Zip code query
  #   ExternalData.location("90210")
  #
  # @example City and state query
  #   ExternalData.location("Los Angeles, CA")

  def self.location(query)
    Rails.logger.info "Fetching location data for query: #{query}"

    response = HTTP.get(USGS_URL + query)
    return unless response.status.success?

    response = response.json[0]

    { lat: response["Latitude"].truncate(2), lon: response["Longitude"].truncate(2) }
  end

  # Grabs station data based on a location object
  # @param location [OpenStruct] an object containing lat and lon attributes
  # @return [Hash] a hash containing weather station information
  #   - :office [String] Three letter office identifier
  #   - :grid_location_x [Integer] X coordinate of the grid location
  #   - :grid_location_y [Integer] Y coordinate of the grid location
  #
  # @example Station query
  #   ExternalData.station(OpenStruct.new({ lat: 34.05, lon: -118.24 })
  def self.station(location)
    Rails.logger.info "Fetching station data for location"

    query_url = "#{STATION}#{location.lat},#{location.lon}"
    response = HTTP.get(query_url)
    return unless response.status.success?

    response = response.json["properties"]
    { office: response["cwa"], grid_location_x: response["gridX"], grid_location_y: response["gridY"] }
  end

  # Grabs forecast data based on a location object
  # @param location [OpenStruct] an object containing office, gridX and gridY attributes
  # @return [Hash] a hash containing forecast information
  #   - :temperature [Integer] Current temperature in Fahrenheit
  #   - :rain_chance [Integer] Chance of rain in percentage
  #   - :wind_speed [String] Wind speed in mph
  #   - :wind_direction [String] Wind direction
  #   - :short_forecast [String] Short forecast description
  #   - :detailed_forecast [String] Detailed forecast description
  #   - :endtime [String] End time of the forecast period
  #
  def self.forecast(location)
    Rails.logger.info "Fetching forecast data for query: #{location}"

    query_url = "#{FORECAST}/#{location.office}/#{location.grid_location_x},#{location.grid_location_y}/forecast"

    response = HTTP.get(query_url)
    return unless response.status.success?

    forecast = response.json["properties"]["periods"][0]
    {
      temperature: forecast["temperature"],
      rain_chance: forecast["probabilityOfPrecipitation"],
      wind_speed: forecast["windSpeed"],
      wind_direction: forecast["windDirection"],
      short_forecast: forecast["shortForecast"],
      detailed_forecast: forecast["detailedForecast"],
      endtime: forecast["endTime"]
    }
  end
end
