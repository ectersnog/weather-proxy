# frozen_string_literal: true

class Geodata
  USGS_URL = "https://dashboard.waterdata.usgs.gov/service/geocoder/get/location/1.0?term="

  def self.find_by_zip(zip)
    return Rails.cache.fetch("geodata:#{zip}") if Rails.cache.exist?("geodata:#{zip}")

    puts "Fetching geodata for zip: #{zip}"
    response = HTTP.get(USGS_URL + "#{zip}&include=postal")
    if response.status.success?
      return :not_found unless response.parse(:json).length > 0
      lat = response.parse(:json)[0]["Latitude"].truncate(2)
      lon = response.parse(:json)[0]["Longitude"].truncate(2)
      Rails.cache.write("geodata:#{zip}", { lat:, lon: })
      { lat:, lon: }
    end
  end

  def self.find_by_city(city, state)
    return Rails.cache.fetch("geodata:#{city},#{state}") if Rails.cache.exist?("geodata:#{city},#{state}")

    puts "Fetching geodata for city: #{city}, state: #{state}"
    response = HTTP.get(USGS_URL + "#{city}&states=#{state}")
    if response.status.success?
      lat = response.parse(:json)[0]["Latitude"].truncate(2)
      lon = response.parse(:json)[0]["Longitude"].truncate(2)
      Rails.cache.write("geodata:#{city},#{state}", { lat:, lon: })
      { lat:, lon: }
    end
  end
end
