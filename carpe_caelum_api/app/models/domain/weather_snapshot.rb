# frozen_string_literal: true

# Represents a snapshot of weather data at a specific point in time.
class WeatherSnapshot
  attr_reader :utc, :temperature_apparent, :weather_description

  # Initializes a new WeatherSnapshot.
  #
  # @param utc [Time] the UTC time of the snapshot
  # @param temperature_apparent [Float] the apparent temperature
  # @param weather_description [String] the weather description
  def initialize(utc:, temperature_apparent:, weather_description:)
    @utc = utc
    @temperature_apparent = temperature_apparent
    @weather_description = weather_description
  end
end
