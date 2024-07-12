# app/graphql/types/weather_type.rb
module Types
  class WeatherType < Types::BaseObject
    field :temperature, Float, null: true
    field :five_hr_temperature_low, Float, null: true, method: :fiveHrTemperatureLow
    field :five_hr_temperature_high, Float, null: true, method: :fiveHrTemperatureHigh
    field :description, String, null: true
    field :error_message, String, null: true, method: :errorMessage
  end
end
