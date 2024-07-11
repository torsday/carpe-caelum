# frozen_string_literal: true

require_relative '../models/domain/weather_snapshot'
require_relative '../models/domain/weather_snapshot_collection'
require_relative '../models/domain/weather_descriptions'

class WeatherFactory
  def self.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)
    Rails.logger.debug "Building weather snapshots from Tomorrow.io API response"
    intervals = api_response["data"]["timelines"][0]["intervals"]

    # build the collection of weather snapshot domain objects
    weather_snapshot_dict = {}
    intervals.each do |interval|
      snapshot = self.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval: interval)
      weather_snapshot_dict[interval["startTime"]] = snapshot
    end
# here
    Rails.logger.debug "Completed building weather snapshots"
    WeatherSnapshotCollection.new(weather_snapshots: weather_snapshot_dict)
  rescue => e
    Rails.logger.error "Error in build_weather_snapshots_from_tomorrow_io_timeline_resp: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  def self.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)
    Rails.logger.debug "Building weather snapshot from interval: #{api_response_interval}"
    WeatherSnapshot.new(
      utc: Time.parse(api_response_interval["startTime"]),
      temperature_apparent: api_response_interval["values"]["temperatureApparent"],
      weather_description: translate_tomorrow_io_weather_code_to_weather_description(
        api_response_interval["values"]["weatherCode"].to_s
      )
    )
  rescue => e
    Rails.logger.error "Error in build_weather_snapshot_from_tomorrow_io_timeline_interval: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  private

  def self.translate_tomorrow_io_weather_code_to_weather_description(tomorrow_io_weather_code)
    Rails.logger.debug "Translating weather code: #{tomorrow_io_weather_code}"
    tomorrow_io_weather_codes_to_local_descriptions = {
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

    tomorrow_io_weather_codes_to_local_descriptions[tomorrow_io_weather_code]
  end
end
