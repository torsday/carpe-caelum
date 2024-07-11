# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'net/http/persistent'
require 'zlib'
require 'stringio'
require 'json'

class TomorrowIoApi
  BASE_URL = "https://api.tomorrow.io/v4/timelines"
  FIELDS = %w[
    cloudCover
    precipitationIntensity
    precipitationType
    temperatureApparent
    thunderstormProbability
    uvIndex
    visibility
    weatherCode
    windDirection
    windGust
    windSpeed
  ]
  UNITS = "imperial"
  TIME_STEPS = ["1h"]
  START_TIME = "now"
  END_TIME = "nowPlus5d"
  MAX_RETRIES = 5
  LAT_LON_PRECISION = ENV.fetch("LAT_LON_PRECISION", 8).to_i

  def get_parsed_weather_timeline_for(latitude:, longitude:)
    Rails.logger.info "Querying Tomorrow.io API for latitude: #{latitude}, longitude: #{longitude}"
    api_key = ENV.fetch('TOMORROW_IO_API_KEY') { raise 'TOMORROW_IO_API_KEY not set' }

    retries = 0
    begin
      response = send_request("#{latitude},#{longitude}", api_key)
      json_timeline = get_json_timeline_from_response(response)
      json_timeline
    rescue Net::HTTP::Persistent::Error, Timeout::Error => e
      retries += 1
      if retries <= MAX_RETRIES
        sleep_time = 2**retries
        Rails.logger.info "Retry ##{retries} after #{sleep_time} seconds due to #{e.class}: #{e.message}"
        sleep(sleep_time)
        retry
      else
        Rails.logger.error "Max retries reached. #{e.class}: #{e.message}"
        nil
      end
    rescue => e
      Rails.logger.error "Error fetching weather data: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

  private

  def cache_key(latitude, longitude)
    key_lat = (latitude * 10**LAT_LON_PRECISION).round
    key_lon = (longitude * 10**LAT_LON_PRECISION).round
    "weather-timeline:#{key_lat}:#{key_lon}"
  end

  def send_request(location, api_key)
    uri = URI("#{BASE_URL}?apikey=#{api_key}")
    http = Net::HTTP::Persistent.new
    request = Net::HTTP::Post.new(uri)
    request["accept"] = 'application/json'
    request["Accept-Encoding"] = 'gzip'
    request["content-type"] = 'application/json'
    request.body = request_body(location).to_json

    # Handle SSL settings
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.cert_store = OpenSSL::X509::Store.new
    http.cert_store.set_default_paths

    response = http.request(uri, request)

    if response.code == "429"
      raise Net::HTTP::Persistent::Error, "Too Many Requests"
    end

    response
  rescue StandardError => e
    Rails.logger.error "HTTP request failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  def request_body(location)
    {
      location: location,
      fields: FIELDS,
      units: UNITS,
      timesteps: TIME_STEPS,
      startTime: START_TIME,
      endTime: END_TIME
    }
  end

  def get_json_timeline_from_response(response)
    if response.nil?
      Rails.logger.error "No response received"
      return nil
    end

    Rails.logger.info "Response received with code: #{response.code} and message: #{response.message}"

    if response.code == "200"
      raw_timeline = decompress_response(response)
      parse_response(raw_timeline)
    else
      Rails.logger.error "Error: #{response.code} #{response.message}"
      nil
    end
  end

  def decompress_response(response)
    if response['content-encoding'] == 'gzip'
      Zlib::GzipReader.new(StringIO.new(response.body.to_s)).read
    else
      response.body
    end
  end

  def parse_response(raw_timeline)
    return nil if raw_timeline.empty?

    JSON.parse(raw_timeline)
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parsing failed: #{e.message}"
    nil
  end
end
