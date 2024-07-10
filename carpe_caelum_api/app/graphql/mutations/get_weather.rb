# frozen_string_literal: true

module Mutations
  class GetWeather < BaseMutation
    argument :input, Types::GetWeatherInputType, required: true

    field :temperature, Float, null: false
    field :description, String, null: false

    def resolve(input:)
      location = input[:location]
      lat, lon = location.split(',').map(&:to_f)

      begin
        weather_data = WeatherService.new.get_weather_timeline(lat, lon)
        Rails.logger.info "Weather data fetched: #{weather_data.inspect}"

        if weather_data
          {
            temperature: weather_data["data"]["timelines"][0]["intervals"][0]["values"]["temperatureApparent"],
            description: weather_data["data"]["timelines"][0]["intervals"][0]["values"]["weatherCode"]
          }
        else
          raise GraphQL::ExecutionError, "Error fetching weather data"
        end
      rescue => e
        Rails.logger.error "Error fetching weather data: #{e.message}"
        raise GraphQL::ExecutionError, "Error fetching weather data"
      end
    end
  end
end
