# frozen_string_literal: true

require_relative '../models/domain/weather_snapshot'
require_relative '../models/domain/weather_snapshot_collection'
require_relative '../models/domain/weather_descriptions'

# WeatherFactory is responsible for building weather snapshots and collections
# from the Tomorrow.io API response.
class WeatherFactory
  # Builds a collection of WeatherSnapshot objects from the Tomorrow.io API response.
  #
  # @param api_response [Hash] The parsed JSON response from the Tomorrow.io API.
  # @return [WeatherSnapshotCollection] A collection of weather snapshots.
  # @raise [StandardError] if an error occurs during the process.
  def self.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)
    Rails.logger.debug 'Building weather snapshots from Tomorrow.io API response'
    Rails.logger.debug { "API Response: #{api_response.inspect}" }

    data = fetch_data(api_response)
    timelines = fetch_timelines(data)
    intervals = fetch_intervals(timelines)
    weather_snapshot_dict = build_snapshot_dict(intervals)

    Rails.logger.debug 'Completed building weather snapshots'
    WeatherSnapshotCollection.new(weather_snapshots: weather_snapshot_dict)
  rescue StandardError => e
    log_error('build_weather_snapshots_from_tomorrow_io_timeline_resp', e)
    raise
  end

  # Retrieves the data from the API response.
  #
  # @param api_response [Hash] The parsed JSON response from the Tomorrow.io API.
  # @return [Hash] The data from the API response.
  # @raise [StandardError] if data is not found in the API response.
  def self.fetch_data(api_response)
    data = api_response['data']
    raise 'No data found in the API response' unless data

    data
  end

  # Retrieves the timelines from the data.
  #
  # @param data [Hash] The data from the API response.
  # @return [Array] The timelines from the data.
  # @raise [StandardError] if timelines are not found in the data.
  def self.fetch_timelines(data)
    timelines = data['timelines']
    raise 'No timelines found in the API response' unless timelines

    timelines
  end

  # Retrieves the intervals from the timelines.
  #
  # @param timelines [Array] The timelines from the data.
  # @return [Array] The intervals from the timelines.
  # @raise [StandardError] if intervals are not found in the timelines.
  def self.fetch_intervals(timelines)
    intervals = timelines.dig(0, 'intervals')
    raise 'No intervals found in the API response' unless intervals

    intervals
  end

  # Builds a dictionary of weather snapshots from the intervals.
  #
  # @param intervals [Array] The intervals from the timelines.
  # @return [Hash{String => WeatherSnapshot}] A dictionary of weather snapshots.
  def self.build_snapshot_dict(intervals)
    intervals.each_with_object({}) do |interval, dict|
      snapshot = build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval: interval)
      dict[interval['startTime']] = snapshot
    end
  end

  # Logs an error message and backtrace.
  #
  # @param method [String] The name of the method where the error occurred.
  # @param error [StandardError] The error to log.
  def self.log_error(method, error)
    Rails.logger.error "Error in #{method}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
  end

  # Builds a WeatherSnapshot object from a single interval of the Tomorrow.io API response.
  #
  # @param api_response_interval [Hash] A single interval of the Tomorrow.io API response.
  # @return [WeatherSnapshot] A weather snapshot.
  # @raise [StandardError] if an error occurs during the process.
  # rubocop:disable Metrics/MethodLength
  def self.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)
    Rails.logger.debug { "Building weather snapshot from interval: #{api_response_interval}" }

    WeatherSnapshot.new(
      utc: Time.zone.parse(api_response_interval['startTime']),
      temperature_apparent: api_response_interval.dig('values', 'temperatureApparent'),
      weather_description: translate_tomorrow_io_weather_code_to_weather_description(
        api_response_interval.dig('values', 'weatherCode').to_s
      )
    )
  rescue StandardError => e
    log_error('build_weather_snapshot_from_tomorrow_io_timeline_interval', e)
    raise
  end
  # rubocop:enable Metrics/MethodLength

  # Translates a Tomorrow.io weather code to a local weather description.
  #
  # @param tomorrow_io_weather_code [String] The weather code from Tomorrow.io.
  # @return [String] The local weather description.
  def self.translate_tomorrow_io_weather_code_to_weather_description(tomorrow_io_weather_code)
    Rails.logger.debug { "Translating weather code: #{tomorrow_io_weather_code}" }

    weather_descriptions[tomorrow_io_weather_code] || WeatherDescriptions::UNKNOWN
  end

  # Defines the weather descriptions mapping.
  #
  # @return [Hash{String => String}] A hash mapping weather codes to descriptions.
  # rubocop:disable Metrics/MethodLength
  def self.weather_descriptions
    {
      '0' => WeatherDescriptions::UNKNOWN,
      '1000' => WeatherDescriptions::CLEAR_SUNNY,
      '1100' => WeatherDescriptions::MOSTLY_CLEAR,
      '1101' => WeatherDescriptions::PARTLY_CLOUDY,
      '1102' => WeatherDescriptions::MOSTLY_CLOUDY,
      '1001' => WeatherDescriptions::CLOUDY,
      '2000' => WeatherDescriptions::FOG,
      '2100' => WeatherDescriptions::LIGHT_FOG,
      '4000' => WeatherDescriptions::DRIZZLE,
      '4001' => WeatherDescriptions::RAIN,
      '4200' => WeatherDescriptions::LIGHT_RAIN,
      '4201' => WeatherDescriptions::HEAVY_RAIN,
      '5000' => WeatherDescriptions::SNOW,
      '5001' => WeatherDescriptions::FLURRIES,
      '5100' => WeatherDescriptions::LIGHT_SNOW,
      '5101' => WeatherDescriptions::HEAVY_SNOW,
      '6000' => WeatherDescriptions::FREEZING_DRIZZLE,
      '6001' => WeatherDescriptions::FREEZING_RAIN,
      '6200' => WeatherDescriptions::LIGHT_FREEZING_RAIN,
      '6201' => WeatherDescriptions::HEAVY_FREEZING_RAIN,
      '7000' => WeatherDescriptions::ICE_PELLETS,
      '7101' => WeatherDescriptions::HEAVY_ICE_PELLETS,
      '7102' => WeatherDescriptions::LIGHT_ICE_PELLETS,
      '8000' => WeatherDescriptions::THUNDERSTORM
    }.freeze
  end
  # rubocop:enable Metrics/MethodLength
end
