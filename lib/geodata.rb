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

  def self.find_by_city(query)
    query = query.split.join.downcase
    return Rails.cache.fetch("geodata:#{query}") if Rails.cache.exist?("geodata:#{query}")

    puts "Fetching geodata for city: #{query}"
    if query.include?(",")
      city, state = query.split(",")
      city.strip!
      state.strip!
      response = HTTP.get(USGS_URL + "#{city}&states=#{state}")
    else
      response = HTTP.get(USGS_URL + "#{query}")
    end
    if response.status.success?
      return :not_found unless response.parse(:json).length > 0
      lat = response.parse(:json)[0]["Latitude"].truncate(2)
      lon = response.parse(:json)[0]["Longitude"].truncate(2)
      Rails.cache.write("geodata:#{query}", { lat:, lon: })
      { lat:, lon: }
    end
  end
end
