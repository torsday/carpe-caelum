require 'uri'
require 'net/http'
require 'zlib'
require 'stringio'
require 'json'

class WeatherService
  def get_weather_timeline(location)
    Rails.logger.info "WeatherService#get_weather_timeline called with location: #{location}"

    api_key = ENV['TOMORROW_IO_API_KEY']
    Rails.logger.info "Using Tomorrow.io API Key: #{api_key}"

    # Construct the URI with the API key as a query parameter
    url = URI("https://api.tomorrow.io/v4/timelines?apikey=#{api_key}")

    # Set up the HTTP connection
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    # Create the POST request
    request = Net::HTTP::Post.new(url)
    request["accept"] = 'application/json'
    request["Accept-Encoding"] = 'gzip'
    request["content-type"] = 'application/json'
    request.body = {
      location: location,
      fields: [
        "temperatureApparent", "windSpeed", "windDirection", "windGust",
        "precipitationIntensity", "precipitationType", "visibility",
        "cloudCover", "uvIndex", "weatherCode", "thunderstormProbability"
      ],
      units: "imperial",
      timesteps: ["1h"],
      startTime: "now",
      endTime: "nowPlus5d"
    }.to_json

    # Execute the request and handle the response
    response = http.request(request)
    Rails.logger.info "Response received with code: #{response.code} and message: #{response.message}"

    if response.code == "200"
      raw_timeline = decompress_response(response)
      Rails.logger.info "Decompressed response: #{raw_timeline}"
      return JSON.parse(raw_timeline) unless raw_timeline.empty?
    else
      Rails.logger.error("Error: #{response.code} #{response.message}")
    end
    nil
  end

  private

  def decompress_response(response)
    if response['content-encoding'] == 'gzip'
      gz = Zlib::GzipReader.new(StringIO.new(response.body.to_s))
      raw_timeline = gz.read
      gz.close
      raw_timeline
    else
      response.body
    end
  end
end
