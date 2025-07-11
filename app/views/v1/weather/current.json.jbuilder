# frozen_string_literal: true

json.current do
  json.temperature current[:temperature]
  json.rain_chance current[:rain_chance]
  json.wind_speed current[:wind_speed]
  json.wind_direction current[:wind_direction]
  json.short_forecast current[:short_forecast]
  json.detailed_forecast current[:detailed_forecast]
end
