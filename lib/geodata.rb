# frozen_string_literal: true

class Geodata
  USGS_URL = "https://dashboard.waterdata.usgs.gov/service/geocoder/get/location/1.0?term="

  def self.find_by_zip(zip)
    return Rails.cache.fetch("geodata:#{zip}") if Rails.cache.exist?("geodata:#{zip}")

    Rails.logger.info "Fetching geodata for zip: #{zip}"
    response = HTTP.get(USGS_URL + "#{zip}&include=postal")
    return unless response.status.success?

    return :not_found unless response.parse(:json).length.positive?

    lat = response.parse(:json)[0]["Latitude"].truncate(2)
    lon = response.parse(:json)[0]["Longitude"].truncate(2)
    Rails.cache.write("geodata:#{zip}", { lat:, lon: })
    { lat:, lon: }
  end

  def self.find_by_city(query)
    query = query.split.join.downcase
    return Rails.cache.fetch("geodata:#{query}") if Rails.cache.exist?("geodata:#{query}")

    Rails.logger.info "Fetching geodata for city: #{query}"

    response = if query.include?(",")
      city, state = query.split(",")
      city.strip!
      state.strip!
      HTTP.get(USGS_URL + "#{city}&states=#{state}")
    else
      HTTP.get(USGS_URL + query)
    end
    return unless response.status.success?

    return :not_found unless response.parse(:json).length.positive?

    lat = response.parse(:json)[0]["Latitude"].truncate(2)
    lon = response.parse(:json)[0]["Longitude"].truncate(2)
    Rails.cache.write("geodata:#{query}", { lat:, lon: })
    { lat:, lon: }
  end
end
