# frozen_string_literal: true

require_relative '../../integrations/tomorrow_io_api'
require_relative '../../services/weather_service'

module Mutations
  class GetWeather < BaseMutation
    argument :input, Types::GetWeatherInputType, required: true

    field :temperature, Float, null: true
    field :description, String, null: true
    field :error_message, String, null: true

    def resolve(input:)
      location = input[:location]
      latitude, longitude = location.split(',').map(&:to_f)

      begin
        weather_repo = WeatherRepository.new(
          redis_client: $redis,
          tomorrow_io_wrapper: TomorrowIoApi.new,
          latitude_longitude_precision: ENV.fetch("LAT_LON_PRECISION") { 5 }.to_i
        )
        weather_service = WeatherService.new(weather_repository: weather_repo)

        if weather_service
          {
            temperature: weather_service.get_current_feels_like_temperature_for(latitude: latitude, longitude: longitude),
            description: weather_service.get_current_conditions_for(latitude: latitude, longitude: longitude),
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
