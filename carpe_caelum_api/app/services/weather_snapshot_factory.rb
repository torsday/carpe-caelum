# frozen_string_literal: true

require 'json'

class WeatherSnapshotFactory
  # Converts a WeatherSnapshot object to a JSON string.
  #
  # @param weather_snapshot [WeatherSnapshot] The WeatherSnapshot object to convert.
  # @return [String] The JSON string representation of the WeatherSnapshot object.
  def self.to_json(weather_snapshot)
    {
      utc: weather_snapshot.utc,
      temperature_apparent: weather_snapshot.temperature_apparent,
      weather_description: weather_snapshot.weather_description
    }.to_json
  end

  # Converts a JSON string to a WeatherSnapshot object.
  #
  # @param json_str [String] The JSON string to convert.
  # @return [WeatherSnapshot] The WeatherSnapshot object created from the JSON string.
  def self.from_json(json_str)
    hash = JSON.parse(json_str, symbolize_names: true)
    create_weather_snapshot_from_hash(hash)
  end

  private

  # Creates a WeatherSnapshot object from a hash.
  #
  # @param hash [Hash] The hash containing the weather snapshot data.
  # @return [WeatherSnapshot] The WeatherSnapshot object created from the hash.
  def self.create_weather_snapshot_from_hash(hash)
    WeatherSnapshot.new(
      utc: parse_time(hash[:utc]),
      temperature_apparent: hash[:temperature_apparent],
      weather_description: hash[:weather_description]
    )
  end

  # Parses a string into a Time object.
  #
  # @param utc_str [String] The string representation of the UTC time.
  # @return [Time] The Time object created from the string.
  def self.parse_time(utc_str)
    Time.parse(utc_str)
  rescue ArgumentError
    Rails.logger.error "Invalid time format: #{utc_str}"
    nil
  end
end
