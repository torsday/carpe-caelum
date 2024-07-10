# frozen_string_literal: true

module Mutations
  class GetWeather < BaseMutation
    argument :input, Types::GetWeatherInputType, required: true

    field :temperature, Float, null: false
    field :description, String, null: false
    field :error_message, String, null: true

    def resolve(input:)
      location = input[:location]
      lat, lon = location.split(',').map(&:to_f)

      begin
        weather_data = WeatherService.new.get_weather_timeline(lat, lon)

        if weather_data
          {
            temperature: weather_data["data"]["timelines"][0]["intervals"][0]["values"]["temperatureApparent"],
            description: weather_data["data"]["timelines"][0]["intervals"][0]["values"]["weatherCode"],
            error_message: nil
          }
        else
          raise GraphQL::ExecutionError, "Error fetching weather data"
        end
      rescue => e
        Rails.logger.error "Error fetching weather data: #{e.message}"
        { temperature: nil, description: nil, error_message: e.message }
      end
    end
  end
end
