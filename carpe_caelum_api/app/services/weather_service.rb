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
  REDIS_CACHE_EXPIRATION_IN_SEC = ENV.fetch("REDIS_CACHE_EXPIRATION_IN_MIN", 30).to_i * 60 # translate to seconds
  LAT_LON_PRECISION = ENV.fetch("LAT_LON_PRECISION") { 5 }.to_i
  MAX_RETRIES = 5

  def get_weather_timeline(lat, lon)
    rounded_lat = (lat * 10**LAT_LON_PRECISION).round
    rounded_lon = (lon * 10**LAT_LON_PRECISION).round

    cache_key = "weather-timeline:#{rounded_lat}:#{rounded_lon}"

    cached_data = $redis.get(cache_key)
    if cached_data
      JSON.parse(cached_data)
    else
      Rails.logger.info "Cache miss for #{cache_key}, querying Tomorrow.io API"
      api_key = ENV.fetch('TOMORROW_IO_API_KEY') { raise 'TOMORROW_IO_API_KEY not set' }
      retries = 0

      begin
        response = send_request("#{lat},#{lon}", api_key)
        json_timeline = get_json_timeline_from_response(response)
        if json_timeline
          $redis.set(cache_key, json_timeline.to_json, ex: REDIS_CACHE_EXPIRATION_IN_SEC)
        end
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
      end
    end
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

    response = http.request(request)

    if response.code == "429"
      raise Net::HTTP::Persistent::Error, "Too Many Requests"
    end

    response
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
