# frozen_string_literal: true

module Weather
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
end
