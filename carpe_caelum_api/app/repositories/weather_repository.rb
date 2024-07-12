# frozen_string_literal: true

require_relative '../factories/weather_snapshot_factory'
require_relative '../factories/weather_factory'

class WeatherRepository
  attr_accessor :redis_client, :latitude_longitude_precision, :tomorrow_io_wrapper

  def initialize(redis_client:, tomorrow_io_wrapper:, latitude_longitude_precision:)
    raise ArgumentError, "redis_client cannot be nil" if redis_client.nil?
    raise ArgumentError, "tomorrow_io_wrapper cannot be nil" if tomorrow_io_wrapper.nil?
    raise ArgumentError, "latitude_longitude_precision must be a non-negative integer" unless latitude_longitude_precision.is_a?(Integer) && latitude_longitude_precision >= 0

    @redis_client = redis_client
    @latitude_longitude_precision = latitude_longitude_precision
    @tomorrow_io_wrapper = tomorrow_io_wrapper
  end

  def get_current_feels_like_temperature_for(latitude:, longitude:)
    validate_coordinates(latitude, longitude)
    snapshot = get_snapshot_for(latitude: latitude, longitude: longitude, utc: get_current_utc_rounded_down)
    snapshot.temperature_apparent
  end

  def get_current_conditions_for(latitude:, longitude:)
    validate_coordinates(latitude, longitude)
    snapshot = get_snapshot_for(latitude: latitude, longitude: longitude, utc: get_current_utc_rounded_down)
    snapshot.weather_description
  end

  def get_feels_like_high_and_low_for(latitude, longitude, window_in_hours)
    validate_coordinates(latitude, longitude)
    raise ArgumentError, "window_in_hours must be a positive integer" unless window_in_hours.is_a?(Integer) && window_in_hours > 0

    current_utc = get_current_utc_rounded_down
    snapshot_hash = {}
    for n in 0..(window_in_hours - 1)
      query_utc = current_utc + (n * 60 * 60)
      snapshot = get_snapshot_for(latitude: latitude, longitude: longitude, utc: query_utc + (n * 60 * 60))
      snapshot_hash[query_utc] = snapshot
    end

    snapshot_collection = WeatherSnapshotCollection.new(weather_snapshots: snapshot_hash)

    {
      temp_low: snapshot_collection.get_temp_low,
      temp_high: snapshot_collection.get_temp_high
    }
  end

  private

  def get_snapshot_for(latitude:, longitude:, utc:)
    validate_coordinates(latitude, longitude)
    raise ArgumentError, "utc must be a Time object" unless utc.is_a?(Time)

    key_lat = (latitude * 10**latitude_longitude_precision).round
    key_lon = (longitude * 10**latitude_longitude_precision).round

    redis_key = get_tomorrow_io_timeline_redis_key(key_lat: key_lat, key_lon: key_lon, utc: utc)
    cached_data = redis_client.get(redis_key)
    # Rails.logger.debug "Fetched data from Redis with key #{redis_key}: #{cached_data.inspect}"

    if cached_data
      return WeatherSnapshotFactory.from_json(cached_data)
    else
      # We don't have the data cached, now we to query Tomorrow.IO
      parsed_timeline = tomorrow_io_wrapper.get_parsed_weather_timeline_for(latitude: latitude, longitude: longitude)
      weather_snapshot_collection = WeatherFactory.build_weather_snapshots_from_tomorrow_io_timeline_resp(
        parsed_timeline
      )

      # Rails.logger.debug "weather_snapshot_collection: #{weather_snapshot_collection.inspect}"

      # Persist each WeatherSnapshot individually to redis
      weather_snapshot_collection.get_list_of_snapshots.each do |snapshot|
        redis_key = get_tomorrow_io_timeline_redis_key(key_lat: key_lat, key_lon: key_lon, utc: snapshot.utc)
        # binding.pry
        serialized_snapshot = WeatherSnapshotFactory.to_json(snapshot)
        Rails.logger.debug "Saving to Redis with key #{redis_key}: #{serialized_snapshot.inspect}"
        redis_client.set(redis_key, serialized_snapshot)
      end
    end
    return weather_snapshot_collection.get_weather_snapshot_for(get_current_utc_rounded_down.iso8601)
  rescue => e
    Rails.logger.error "Error in get_snapshot_for: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  def get_tomorrow_io_timeline_redis_key(key_lat:, key_lon:, utc:)
    unless utc.is_a?(Time)
      raise TypeError, "Expected 'utc' to be an instance of Time, but got #{utc.class}"
    end
    "tomorrow-timeline:#{key_lat},#{key_lon}:#{utc.iso8601}"
  end

  def get_current_utc_rounded_down
    Time.now.utc.change(min: 0, sec: 0)
  end

  def validate_coordinates(latitude, longitude)
    raise ArgumentError, "latitude must be between -90 and 90" unless latitude.is_a?(Numeric) && latitude.between?(-90, 90)
    raise ArgumentError, "longitude must be between -180 and 180" unless longitude.is_a?(Numeric) && longitude.between?(-180, 180)
  end
end
