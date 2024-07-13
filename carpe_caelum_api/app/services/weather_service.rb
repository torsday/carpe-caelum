# frozen_string_literal: true

class WeatherService
  attr_accessor :weather_repository

  REDIS_CACHE_EXPIRATION_IN_SEC = ENV.fetch('REDIS_CACHE_EXPIRATION_IN_MIN', 30).to_i * 60 # Translate to seconds
  LAT_LON_PRECISION = ENV.fetch('LAT_LON_PRECISION', 5).to_i

  # Initializes a new WeatherService.
  #
  # @param weather_repository [WeatherRepository] the repository for accessing weather data
  def initialize(weather_repository:)
    @weather_repository = weather_repository
  end

  # Retrieves the current 'feels like' temperature for the given coordinates.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @return [Float] the 'feels like' temperature
  def get_current_feels_like_temperature_for(latitude:, longitude:)
    weather_repository.get_current_feels_like_temperature_for(latitude:, longitude:)
  end

  # Retrieves the low 'feels like' temperature for the next 5 hours for the given coordinates.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @return [Float] the low 'feels like' temperature
  def get_5_hr_temperature_low_for(latitude:, longitude:)
    get_feels_like_high_and_low_for(latitude:, longitude:, window_in_hours: 5)[:temp_low]
  end

  # Retrieves the high 'feels like' temperature for the next 5 hours for the given coordinates.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @return [Float] the high 'feels like' temperature
  def get_5_hr_temperature_high_for(latitude:, longitude:)
    get_feels_like_high_and_low_for(latitude:, longitude:, window_in_hours: 5)[:temp_high]
  end

  # Retrieves the high and low 'feels like' temperatures for a given time window.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @param window_in_hours [Integer] the number of hours to look ahead
  # @return [Hash] a hash containing the high and low 'feels like' temperatures
  def get_feels_like_high_and_low_for(latitude:, longitude:, window_in_hours: 24)
    weather_repository.get_feels_like_high_and_low_for(latitude, longitude, window_in_hours)
  end

  # Retrieves the current weather conditions for the given coordinates.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @return [String] the weather description
  def get_current_conditions_for(latitude:, longitude:)
    weather_repository.get_current_conditions_for(latitude:, longitude:)
  end
end
