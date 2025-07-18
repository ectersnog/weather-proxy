# frozen_string_literal: true

class Geodata
  # Class to return the location information based on query string.
  # @param query [String]
  # @example
  #   - 'Los Angeles, CA' - City and state
  #   - 'Los Angeles' - City only
  #   - '90210' - Zip code
  # @return [WeatherData::Location] The location information from the WeatherData service.
  def self.find(query)
    query_string = if query.match?(/\d{5}/)
      "#{query} + &include=postal"
    elsif query.include?(",")
      city, state = query.split(",")
      "#{city.strip}&states=#{state.strip}"
    else
      query
    end

    WeatherData.location(query_string)
  end
end
