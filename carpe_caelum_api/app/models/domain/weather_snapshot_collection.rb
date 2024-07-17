# frozen_string_literal: true

# Represents a collection of WeatherSnapshot objects.
class WeatherSnapshotCollection
  attr_reader :weather_snapshots

  # Initializes a new WeatherSnapshotCollection.
  #
  # @param weather_snapshots [Hash{String => WeatherSnapshot}] a hash mapping UTC times to WeatherSnapshot objects
  def initialize(weather_snapshots:)
    @weather_snapshots = weather_snapshots
  end

  # Retrieves the highest apparent temperature in the collection.
  #
  # @return [Float, nil] the highest apparent temperature or nil if the collection is empty
  def temp_high
    weather_snapshots.values.map(&:temperature_apparent).max
  end

  # Retrieves the lowest apparent temperature in the collection.
  #
  # @return [Float, nil] the lowest apparent temperature or nil if the collection is empty
  def temp_low
    weather_snapshots.values.map(&:temperature_apparent).min
  end

  # Retrieves the earliest UTC time in the collection.
  #
  # @return [String, nil] the earliest UTC time or nil if the collection is empty
  def utc_start
    weather_snapshots.keys.min
  end

  # Retrieves the latest UTC time in the collection.
  #
  # @return [String, nil] the latest UTC time or nil if the collection is empty
  def utc_end
    weather_snapshots.keys.max
  end

  # Retrieves a list of all WeatherSnapshot objects in the collection.
  #
  # @return [Array<WeatherSnapshot>] the list of WeatherSnapshot objects
  def list_of_snapshots
    weather_snapshots.values
  end

  # Retrieves a WeatherSnapshot object for a specific UTC time.
  #
  # @param utc [String] the UTC time
  # @return [WeatherSnapshot, nil] the WeatherSnapshot object or nil if not found
  def weather_snapshot_for(utc)
    weather_snapshots[utc]
  end
end
