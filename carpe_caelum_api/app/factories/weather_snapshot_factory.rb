# frozen_string_literal: true

require 'json'

class WeatherSnapshotFactory
  def self.to_json(weather_snapshot)
    {
      utc: weather_snapshot.utc,
      temperature_apparent: weather_snapshot.temperature_apparent,
      weather_description: weather_snapshot.weather_description
    }.to_json
  end

  def self.from_json(json_str)
    hash = JSON.parse(json_str)
    WeatherSnapshot.new(
      utc: hash['utc'],
      temperature_apparent: hash['temperature_apparent'],
      weather_description: hash['weather_description']
    )
  end
end
