require 'rails_helper'
require_relative '../../app/models/domain/weather_snapshot'

RSpec.describe WeatherSnapshot do
  let(:utc) { '2023-07-03T12:00:00Z' }
  let(:temperature_apparent) { 75.0 }
  let(:weather_description) { 'Sunny' }
  let(:weather_snapshot) { WeatherSnapshot.new(utc: utc, temperature_apparent: temperature_apparent, weather_description: weather_description) }

  describe '#initialize' do
    it 'creates an instance of WeatherSnapshot with correct attributes' do
      expect(weather_snapshot.utc).to eq(utc)
      expect(weather_snapshot.temperature_apparent).to eq(temperature_apparent)
      expect(weather_snapshot.weather_description).to eq(weather_description)
    end
  end

  describe '#utc' do
    it 'allows reading and writing for :utc' do
      new_utc = '2024-07-03T12:00:00Z'
      weather_snapshot.utc = new_utc
      expect(weather_snapshot.utc).to eq(new_utc)
    end
  end

  describe '#temperature_apparent' do
    it 'allows reading and writing for :temperature_apparent' do
      new_temperature = 80.0
      weather_snapshot.temperature_apparent = new_temperature
      expect(weather_snapshot.temperature_apparent).to eq(new_temperature)
    end
  end

  describe '#weather_description' do
    it 'allows reading and writing for :weather_description' do
      new_description = 'Cloudy'
      weather_snapshot.weather_description = new_description
      expect(weather_snapshot.weather_description).to eq(new_description)
    end
  end
end
