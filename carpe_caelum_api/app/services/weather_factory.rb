# frozen_string_literal: true

require_relative '../models/domain/weather_snapshot'
require_relative '../models/domain/weather_snapshot_collection'
require_relative '../models/domain/weather_descriptions'

class WeatherFactory
  # Builds a collection of WeatherSnapshot objects from the Tomorrow.io API response.
  #
  # @param api_response [Hash] The parsed JSON response from the Tomorrow.io API.
  # @return [WeatherSnapshotCollection] A collection of weather snapshots.
  # @raise [StandardError] if an error occurs during the process.
  def self.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)
    Rails.logger.debug "Building weather snapshots from Tomorrow.io API response"

    intervals = api_response.dig("data", "timelines", 0, "intervals")
    raise "No intervals found in the API response" unless intervals

    # Create a hash of weather snapshots, with the interval start time as the key
    weather_snapshot_dict = intervals.each_with_object({}) do |interval, dict|
      snapshot = build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval: interval)
      dict[interval["startTime"]] = snapshot
    end

    Rails.logger.debug "Completed building weather snapshots"
    WeatherSnapshotCollection.new(weather_snapshots: weather_snapshot_dict)
  rescue => e
    Rails.logger.error "Error in build_weather_snapshots_from_tomorrow_io_timeline_resp: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  # Builds a WeatherSnapshot object from a single interval of the Tomorrow.io API response.
  #
  # @param api_response_interval [Hash] A single interval of the Tomorrow.io API response.
  # @return [WeatherSnapshot] A weather snapshot.
  # @raise [StandardError] if an error occurs during the process.
  def self.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)
    Rails.logger.debug "Building weather snapshot from interval: #{api_response_interval}"

    WeatherSnapshot.new(
      utc: Time.parse(api_response_interval["startTime"]),
      temperature_apparent: api_response_interval.dig("values", "temperatureApparent"),
      weather_description: translate_tomorrow_io_weather_code_to_weather_description(
        api_response_interval.dig("values", "weatherCode").to_s
      )
    )
  rescue => e
    Rails.logger.error "Error in build_weather_snapshot_from_tomorrow_io_timeline_interval: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  private

  # Translates a Tomorrow.io weather code to a local weather description.
  #
  # @param tomorrow_io_weather_code [String] The weather code from Tomorrow.io.
  # @return [String] The local weather description.
  def self.translate_tomorrow_io_weather_code_to_weather_description(tomorrow_io_weather_code)
    Rails.logger.debug "Translating weather code: #{tomorrow_io_weather_code}"

    weather_descriptions = {
      "0" => WeatherDescriptions::UNKNOWN,
      "1000" => WeatherDescriptions::CLEAR_SUNNY,
      "1100" => WeatherDescriptions::MOSTLY_CLEAR,
      "1101" => WeatherDescriptions::PARTLY_CLOUDY,
      "1102" => WeatherDescriptions::MOSTLY_CLOUDY,
      "1001" => WeatherDescriptions::CLOUDY,
      "2000" => WeatherDescriptions::FOG,
      "2100" => WeatherDescriptions::LIGHT_FOG,
      "4000" => WeatherDescriptions::DRIZZLE,
      "4001" => WeatherDescriptions::RAIN,
      "4200" => WeatherDescriptions::LIGHT_RAIN,
      "4201" => WeatherDescriptions::HEAVY_RAIN,
      "5000" => WeatherDescriptions::SNOW,
      "5001" => WeatherDescriptions::FLURRIES,
      "5100" => WeatherDescriptions::LIGHT_SNOW,
      "5101" => WeatherDescriptions::HEAVY_SNOW,
      "6000" => WeatherDescriptions::FREEZING_DRIZZLE,
      "6001" => WeatherDescriptions::FREEZING_RAIN,
      "6200" => WeatherDescriptions::LIGHT_FREEZING_RAIN,
      "6201" => WeatherDescriptions::HEAVY_FREEZING_RAIN,
      "7000" => WeatherDescriptions::ICE_PELLETS,
      "7101" => WeatherDescriptions::HEAVY_ICE_PELLETS,
      "7102" => WeatherDescriptions::LIGHT_ICE_PELLETS,
      "8000" => WeatherDescriptions::THUNDERSTORM
    }.freeze

    # Return the local weather description or UNKNOWN if the code is not found
    weather_descriptions[tomorrow_io_weather_code] || WeatherDescriptions::UNKNOWN
  end
end
