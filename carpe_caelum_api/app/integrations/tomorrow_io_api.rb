# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'net/http/persistent'
require 'zlib'
require 'stringio'
require 'json'

# This class interacts with the Tomorrow.io API to fetch weather timelines.
class TomorrowIoApi
  BASE_URL = 'https://api.tomorrow.io/v4/timelines'
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
  ].freeze
  UNITS = 'imperial'
  TIME_STEPS = ['1h'].freeze
  START_TIME = 'now'
  END_TIME = 'nowPlus5d'
  MAX_RETRIES = 5
  LAT_LON_PRECISION = ENV.fetch('LAT_LON_PRECISION', 8).to_i

  # Fetches and parses the weather timeline for a given latitude and longitude.
  #
  # @param latitude [Float] the latitude of the location
  # @param longitude [Float] the longitude of the location
  # @return [Hash, nil] the parsed weather timeline or nil if an error occurs
  def get_parsed_weather_timeline_for(latitude:, longitude:)
    Rails.logger.info "Querying Tomorrow.io API for latitude: #{latitude}, longitude: #{longitude}"
    api_key = fetch_api_key

    retries = 0
    begin
      response = send_request("#{latitude},#{longitude}", api_key)
      process_response(response)
    rescue Net::HTTP::Persistent::Error, Timeout::Error => e
      retries += 1
      if retries <= MAX_RETRIES
        sleep_time = 2**retries
        Rails.logger.info "Retry ##{retries} after #{sleep_time} seconds due to #{e.class}: #{e.message}"
        sleep(sleep_time)
        retry
      else
        log_error('Max retries reached', e)
        nil
      end
    rescue StandardError => e
      log_error('Error fetching weather data', e)
      nil
    end
  end

  private

  # Fetches the Tomorrow.io API key from environment variables.
  #
  # @return [String] the API key
  # @raise [RuntimeError] if the API key is not set
  def fetch_api_key
    ENV.fetch('TOMORROW_IO_API_KEY') { raise 'TOMORROW_IO_API_KEY not set' }
  end

  # Logs an error message with the backtrace.
  #
  # @param message [String] the error message
  # @param error [Exception] the exception to log
  def log_error(message, error)
    Rails.logger.error "#{message}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
  end

  # Generates a cache key for Redis based on latitude and longitude.
  #
  # @param latitude [Float] the latitude of the location
  # @param longitude [Float] the longitude of the location
  # @return [String] the generated cache key
  def cache_key(latitude, longitude)
    key_lat = (latitude * (10**LAT_LON_PRECISION)).round
    key_lon = (longitude * (10**LAT_LON_PRECISION)).round
    "weather-timeline:#{key_lat}:#{key_lon}"
  end

  # Sends an HTTP request to the Tomorrow.io API.
  #
  # @param location [String] the location in "latitude,longitude" format
  # @param api_key [String] the API key for authentication
  # @return [Net::HTTPResponse, nil] the HTTP response or nil if an error occurs
  def send_request(location, api_key)
    uri = URI("#{BASE_URL}?apikey=#{api_key}")
    http = Net::HTTP::Persistent.new
    request = build_request(uri, location)

    configure_http(http)

    response = http.request(uri, request)
    handle_rate_limiting(response)

    response
  rescue StandardError => e
    log_error('HTTP request failed', e)
    nil
  end

  # Builds an HTTP request with the necessary headers and body.
  #
  # @param uri [URI] the URI for the request
  # @param location [String] the location in "latitude,longitude" format
  # @return [Net::HTTP::Post] the constructed HTTP request
  def build_request(uri, location)
    request = Net::HTTP::Post.new(uri)
    request['accept'] = 'application/json'
    request['Accept-Encoding'] = 'gzip'
    request['content-type'] = 'application/json'
    request.body = request_body(location).to_json
    request
  end

  # Configures the HTTP client with SSL settings.
  #
  # @param http [Net::HTTP::Persistent] the HTTP client
  def configure_http(http)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.cert_store = OpenSSL::X509::Store.new
    http.cert_store.set_default_paths
  end

  # Handles rate limiting by raising an error if too many requests are made.
  #
  # @param response [Net::HTTPResponse] the HTTP response
  # @raise [Net::HTTP::Persistent::Error] if the response code indicates rate limiting
  def handle_rate_limiting(response)
    raise Net::HTTP::Persistent::Error, 'Too Many Requests' if response.code == '429'
  end

  # Constructs the body for the API request.
  #
  # @param location [String] the location in "latitude,longitude" format
  # @return [Hash] the request body as a hash
  def request_body(location)
    {
      location:,
      fields: FIELDS,
      units: UNITS,
      timesteps: TIME_STEPS,
      startTime: START_TIME,
      endTime: END_TIME
    }
  end

  # Processes the response from the API.
  #
  # @param response [Net::HTTPResponse, nil] the HTTP response
  # @return [Hash, nil] the parsed JSON timeline or nil if an error occurs
  def process_response(response)
    return log_no_response unless response

    Rails.logger.info "Response received with code: #{response.code} and message: #{response.message}"

    response.code == '200' ? parse_valid_response(response) : log_invalid_response(response)
  end

  # Logs and returns nil if no response is received.
  #
  # @return [nil]
  def log_no_response
    Rails.logger.error 'No response received'
    nil
  end

  # Logs an invalid response and returns nil.
  #
  # @param response [Net::HTTPResponse] the HTTP response
  # @return [nil]
  def log_invalid_response(response)
    Rails.logger.error "Error: #{response.code} #{response.message}"
    nil
  end

  # Parses a valid response.
  #
  # @param response [Net::HTTPResponse] the HTTP response
  # @return [Hash, nil] the parsed JSON timeline or nil if an error occurs
  def parse_valid_response(response)
    raw_timeline = decompress_response(response)
    parse_response(raw_timeline)
  end

  # Decompresses the response if it is gzipped.
  #
  # @param response [Net::HTTPResponse] the HTTP response
  # @return [String] the decompressed response body
  def decompress_response(response)
    response['content-encoding'] == 'gzip' ? Zlib::GzipReader.new(StringIO.new(response.body.to_s)).read : response.body
  end

  # Parses the raw JSON timeline from the response.
  #
  # @param raw_timeline [String] the raw JSON timeline
  # @return [Hash, nil] the parsed JSON or nil if parsing fails
  def parse_response(raw_timeline)
    JSON.parse(raw_timeline).tap do |parsed|
      raise JSON::ParserError if parsed.empty?
    end
  rescue JSON::ParserError => e
    log_error('JSON parsing failed', e)
    nil
  end
end
