# frozen_string_literal: true

# app/graphql/types/weather_type.rb
module Types
  class WeatherType < Types::BaseObject
    field :description, String, null: true
    field :error_message, String, null: true, method: :errorMessage
    field :five_hr_temperature_high, Float, null: true, method: :fiveHrTemperatureHigh
    field :five_hr_temperature_low, Float, null: true, method: :fiveHrTemperatureLow
    field :temperature, Float, null: true
  end
end
