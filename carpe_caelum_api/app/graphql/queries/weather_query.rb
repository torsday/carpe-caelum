# frozen_string_literal: true

module Queries
  class WeatherQuery < GraphQL::Schema::Resolver
    type Types::WeatherType, null: true

    argument :latitude, Float, required: true
    argument :longitude, Float, required: true

    def resolve(latitude:, longitude:)
      begin
        weather_repo = WeatherRepository.new(
          redis_client: $redis,
          tomorrow_io_wrapper: TomorrowIoApi.new,
          latitude_longitude_precision: ENV.fetch("LAT_LON_PRECISION") { 5 }.to_i
        )
        weather_service = WeatherService.new(weather_repository: weather_repo)

        {
          temperature: weather_service.get_current_feels_like_temperature_for(latitude: latitude, longitude: longitude),
          fiveHrTemperatureLow: weather_service.get_5_hr_temperature_low_for(latitude: latitude, longitude: longitude),
          fiveHrTemperatureHigh: weather_service.get_5_hr_temperature_high_for(latitude: latitude, longitude: longitude),
          description: weather_service.get_current_conditions_for(latitude: latitude, longitude: longitude),
          errorMessage: nil
        }
      rescue => e
        Rails.logger.error "Error fetching weather data: #{e.message}"
        {
          temperature: nil,
          fiveHrTemperatureLow: nil,
          fiveHrTemperatureHigh: nil,
          description: nil,
          errorMessage: e.message
        }
      end
    end
  end
end
