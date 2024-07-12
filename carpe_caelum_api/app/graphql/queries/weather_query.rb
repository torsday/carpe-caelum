# frozen_string_literal: true

module Queries
  # WeatherQuery is a GraphQL resolver for fetching weather data.
  class WeatherQuery < GraphQL::Schema::Resolver
    type Types::WeatherType, null: true

    argument :latitude, Float, required: true
    argument :longitude, Float, required: true

    # Resolves the weather data for given latitude and longitude.
    #
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @return [Hash] a hash containing weather data or an error message
    def resolve(latitude:, longitude:)
      weather_service = initialize_weather_service

      {
        temperature: fetch_current_temperature(weather_service, latitude, longitude),
        fiveHrTemperatureLow: fetch_temperature_low(weather_service, latitude, longitude),
        fiveHrTemperatureHigh: fetch_temperature_high(weather_service, latitude, longitude),
        description: fetch_current_conditions(weather_service, latitude, longitude),
        errorMessage: nil
      }
    rescue => e
      handle_error(e)
    end

    private

    # Initializes the WeatherService.
    #
    # @return [WeatherService] the initialized WeatherService
    def initialize_weather_service
      weather_repo = WeatherRepository.new(
        redis_client: $redis,
        tomorrow_io_wrapper: TomorrowIoApi.new,
        latitude_longitude_precision: ENV.fetch("LAT_LON_PRECISION") { 5 }.to_i
      )
      WeatherService.new(weather_repository: weather_repo)
    end

    # Fetches the current 'feels like' temperature.
    #
    # @param weather_service [WeatherService] the weather service
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @return [Float, nil] the current 'feels like' temperature or nil if an error occurs
    def fetch_current_temperature(weather_service, latitude, longitude)
      weather_service.get_current_feels_like_temperature_for(latitude: latitude, longitude: longitude)
    end

    # Fetches the low 'feels like' temperature for the next 5 hours.
    #
    # @param weather_service [WeatherService] the weather service
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @return [Float, nil] the low 'feels like' temperature or nil if an error occurs
    def fetch_temperature_low(weather_service, latitude, longitude)
      weather_service.get_5_hr_temperature_low_for(latitude: latitude, longitude: longitude)
    end

    # Fetches the high 'feels like' temperature for the next 5 hours.
    #
    # @param weather_service [WeatherService] the weather service
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @return [Float, nil] the high 'feels like' temperature or nil if an error occurs
    def fetch_temperature_high(weather_service, latitude, longitude)
      weather_service.get_5_hr_temperature_high_for(latitude: latitude, longitude: longitude)
    end

    # Fetches the current weather conditions.
    #
    # @param weather_service [WeatherService] the weather service
    # @param latitude [Float] the latitude of the location
    # @param longitude [Float] the longitude of the location
    # @return [String, nil] the current weather conditions or nil if an error occurs
    def fetch_current_conditions(weather_service, latitude, longitude)
      weather_service.get_current_conditions_for(latitude: latitude, longitude: longitude)
    end

    # Handles errors by logging and returning an error message.
    #
    # @param error [Exception] the error to handle
    # @return [Hash] a hash containing error information
    def handle_error(error)
      Rails.logger.error "Error fetching weather data: #{error.message}"
      {
        temperature: nil,
        fiveHrTemperatureLow: nil,
        fiveHrTemperatureHigh: nil,
        description: nil,
        errorMessage: error.message
      }
    end
  end
end
