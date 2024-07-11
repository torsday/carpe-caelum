# frozen_string_literal: true



class WeatherService

  attr_accessor :weather_repository

  REDIS_CACHE_EXPIRATION_IN_SEC = ENV.fetch("REDIS_CACHE_EXPIRATION_IN_MIN", 30).to_i * 60 # translate to seconds
  LAT_LON_PRECISION = ENV.fetch("LAT_LON_PRECISION") { 5 }.to_i

  def initialize(weather_repository:)
    @weather_repository = weather_repository
  end

  def get_current_feels_like_temperature_for(latitude:, longitude:)
    weather_repository.get_current_feels_like_temperature_for(latitude: latitude, longitude:longitude)
  end

  def get_feels_like_high_and_low_for(latitude:, longitude:, window_in_hours: 24)
    weather_repository.get_feels_like_high_and_low_for(latitude, longitude, window_in_hours)
  end

  def get_current_conditions_for(latitude:, longitude:)
    weather_repository.get_current_conditions_for(latitude:latitude, longitude:longitude)
  end

end
