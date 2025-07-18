# frozen_string_literal: true

WeatherResult = Struct.new(:success?, :success, :failure)
CurrentWeatherResult = Struct.new(
  :temperature,
  :rain_chance,
  :wind_speed,
  :wind_direction,
  :short_forecast,
  :detailed_forecast,
  :endtime
)
