# frozen_string_literal: true

require_relative '../services/weather_snapshot_factory'
require_relative '../services/weather_factory'

# WeatherRepository is responsible for fetching and caching weather data
# from external APIs and Redis.
class WeatherRepository
  attr_accessor :redis_client, :latitude_longitude_precision, :tomorrow_io_wrapper

  # Initializes a new WeatherRepository.
  #
  # @param redis_client [Object] the Redis client
  # @param tomorrow_io_wrapper [Object] the Tomorrow.io API wrapper
  # @param latitude_longitude_precision [Integer] the precision for latitude and longitude
  #
  # @raise [ArgumentError] if any argument is nil or invalid
  def initialize(redis_client:, tomorrow_io_wrapper:, latitude_longitude_precision:)
    raise ArgumentError, 'redis_client cannot be nil' if redis_client.nil?
    raise ArgumentError, 'tomorrow_io_wrapper cannot be nil' if tomorrow_io_wrapper.nil?

    unless latitude_longitude_precision.is_a?(Integer) && latitude_longitude_precision >= 0
      raise ArgumentError, 'latitude_longitude_precision must be a non-negative integer'
    end

    @redis_client = redis_client
    @latitude_longitude_precision = latitude_longitude_precision
    @tomorrow_io_wrapper = tomorrow_io_wrapper
  end

  # Retrieves the current 'feels like' temperature for the given coordinates.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @return [Float] the 'feels like' temperature
  def current_feels_like_temperature_for(latitude:, longitude:)
    validate_coordinates(latitude, longitude)
    snapshot = snapshot_for(latitude:, longitude:, utc: current_utc_rounded_down)
    snapshot.temperature_apparent
  end

  # Retrieves the current weather conditions for the given coordinates.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @return [String] the weather description
  def current_conditions_for(latitude:, longitude:)
    validate_coordinates(latitude, longitude)
    snapshot = snapshot_for(latitude:, longitude:, utc: current_utc_rounded_down)
    snapshot.weather_description
  end

  # Retrieves the high and low 'feels like' temperatures for a given window.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @param window_in_hours [Integer] the number of hours to look ahead
  # @return [Hash] a hash containing the high and low 'feels like' temperatures
  def feels_like_high_and_low_for(latitude:, longitude:, window_in_hours:)
    validate_coordinates(latitude, longitude)
    validate_window_in_hours(window_in_hours)

    snapshot_collection = build_snapshot_collection(latitude:, longitude:,
                                                    window_in_hours:)

    {
      temp_low: snapshot_collection.temp_low,
      temp_high: snapshot_collection.temp_high
    }
  end

  private

  def build_snapshot_collection(latitude:, longitude:, window_in_hours:)
    current_utc = current_utc_rounded_down
    snapshot_hash = {}
    (0...window_in_hours).each do |n|
      query_utc = current_utc + (n * 3600) # Using 3600 seconds (1 hour) instead of 60*60
      snapshot = snapshot_for(latitude:, longitude:, utc: query_utc)
      snapshot_hash[query_utc] = snapshot
    end
    WeatherSnapshotCollection.new(weather_snapshots: snapshot_hash)
  end

  # Retrieves a weather snapshot for the given coordinates and time.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @param utc [Time] the UTC time
  # @return [WeatherSnapshot] the weather snapshot
  #
  # @raise [ArgumentError] if the coordinates or time are invalid
  def snapshot_for(latitude:, longitude:, utc:)
    validate_coordinates(latitude, longitude)
    validate_utc(utc)

    redis_key = tomorrow_io_timeline_redis_key(latitude:, longitude:, utc:)
    cached_data = redis_client.get(redis_key)

    if cached_data
      WeatherSnapshotFactory.from_json(cached_data)
    else
      query_external_api_for_weather_snapshot(latitude:, longitude:, _utc: utc)
    end
  rescue StandardError => e
    log_error('snapshot_for', e)
    raise
  end

  # Queries the external API for weather snapshots and caches them in Redis.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @param _utc [Time] the UTC time (unused)
  # @return [WeatherSnapshot] the weather snapshot
  def query_external_api_for_weather_snapshot(latitude:, longitude:, _utc:)
    parsed_timeline = tomorrow_io_wrapper.get_parsed_weather_timeline_for(latitude:, longitude:)
    weather_snapshot_collection = WeatherFactory.build_weather_snapshots_from_tomorrow_io_timeline_resp(parsed_timeline)

    weather_snapshot_collection.list_of_snapshots.each do |snapshot|
      redis_key = tomorrow_io_timeline_redis_key(latitude:, longitude:, utc: snapshot.utc)
      serialized_snapshot = WeatherSnapshotFactory.to_json(snapshot)

      Rails.logger.debug { "Saving to Redis with key #{redis_key}: #{serialized_snapshot.inspect}" }

      redis_client.set(redis_key, serialized_snapshot)
    end

    weather_snapshot_collection.weather_snapshot_for(current_utc_rounded_down.iso8601)
  end

  # Generates a Redis key for the given latitude, longitude, and time.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  # @param utc [Time] the UTC time
  # @return [String] the Redis key
  def tomorrow_io_timeline_redis_key(latitude:, longitude:, utc:)
    raise TypeError, "Expected 'utc' to be an instance of Time, but got #{utc.class}" unless utc.is_a?(Time)

    key_lat = (latitude * (10**latitude_longitude_precision)).round
    key_lon = (longitude * (10**latitude_longitude_precision)).round

    "tomorrow-timeline:#{key_lat},#{key_lon}:#{utc.iso8601}"
  end

  # Retrieves the current UTC time rounded down to the nearest hour.
  #
  # @return [Time] the current UTC time rounded down
  def current_utc_rounded_down
    Time.now.utc.change(min: 0, sec: 0)
  end

  # Validates the given coordinates.
  #
  # @param latitude [Float] the latitude
  # @param longitude [Float] the longitude
  #
  # @raise [ArgumentError] if the coordinates are invalid
  def validate_coordinates(latitude, longitude)
    raise ArgumentError, 'latitude must be between -90 and 90' unless latitude.is_a?(Numeric) && latitude.between?(-90,
                                                                                                                   90)
    raise ArgumentError, 'longitude must be between -180 and 180' unless longitude.is_a?(Numeric) && longitude.between?(
      -180, 180
    )
  end

  # Validates the given UTC time.
  #
  # @param utc [Time] the UTC time
  #
  # @raise [ArgumentError] if the UTC time is invalid
  def validate_utc(utc)
    raise ArgumentError, 'utc must be a Time object' unless utc.is_a?(Time)
  end

  # Validates the window in hours.
  #
  # @param window_in_hours [Integer] the number of hours to look ahead
  #
  # @raise [ArgumentError] if the window in hours is invalid
  def validate_window_in_hours(window_in_hours)
    return if window_in_hours.is_a?(Integer) && window_in_hours.positive?

    raise ArgumentError, 'window_in_hours must be a positive integer'
  end

  def log_error(method, error)
    Rails.logger.error "Error in #{method}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
  end
end
