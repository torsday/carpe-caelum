# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'zlib'
require 'stringio'
require 'json'

class WeatherService
  BASE_URL = "https://api.tomorrow.io/v4/timelines"
  FIELDS = %w[
    temperatureApparent windSpeed windDirection windGust
    precipitationIntensity precipitationType visibility
    cloudCover uvIndex weatherCode thunderstormProbability
  ]
  UNITS = "imperial"
  TIME_STEPS = ["1h"]
  START_TIME = "now"
  END_TIME = "nowPlus5d"

  def get_weather_timeline(location)
    api_key = ENV.fetch('TOMORROW_IO_API_KEY') { raise 'TOMORROW_IO_API_KEY not set' }
    response = send_request(location, api_key)
    json_timline = get_json_timeline_from_response(response)
    json_timline
  end

  private

  def send_request(location, api_key)
    url = URI("#{BASE_URL}?apikey=#{api_key}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = 'application/json'
    request["Accept-Encoding"] = 'gzip'
    request["content-type"] = 'application/json'
    request.body = request_body(location).to_json

    http.request(request)
  rescue StandardError => e
    Rails.logger.error "HTTP request failed: #{e.message}"
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
