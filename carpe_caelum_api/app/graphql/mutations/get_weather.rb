# frozen_string_literal: true

module Mutations
  class GetWeather < BaseMutation
    argument :input, Types::GetWeatherInputType, required: true

    field :temperature, Float, null: false
    field :description, String, null: false

    def resolve(input:)
      location = input[:location]
      Rails.logger.info "GetWeather Mutation called with location: #{location}"

      begin
        weather_data = WeatherService.new.get_weather_timeline(location)
        Rails.logger.info "Weather data fetched: #{weather_data.inspect}"

        if weather_data
          {
            temperature: weather_data['temperatureApparent']['value'],
            description: weather_data['weatherCode']['value']
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
