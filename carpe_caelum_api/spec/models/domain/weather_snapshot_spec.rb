# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../app/models/domain/weather_snapshot'

RSpec.describe WeatherSnapshot do
  let(:utc_time) { Time.now.utc }
  let(:temperature_apparent) { 75.0 }
  let(:weather_description) { 'Sunny' }
  let(:weather_snapshot) do
    described_class.new(
      utc: utc_time,
      temperature_apparent:,
      weather_description:
    )
  end

  describe '#initialize' do
    it 'creates a new WeatherSnapshot with the correct attributes' do
      expect(weather_snapshot.utc).to eq(utc_time)
      expect(weather_snapshot.temperature_apparent).to eq(temperature_apparent)
      expect(weather_snapshot.weather_description).to eq(weather_description)
    end

    it 'raises an error if utc is not provided' do
      expect do
        described_class.new(
          temperature_apparent:,
          weather_description:
        )
      end.to raise_error(ArgumentError)
    end

    it 'raises an error if temperature_apparent is not provided' do
      expect do
        described_class.new(
          utc: utc_time,
          weather_description:
        )
      end.to raise_error(ArgumentError)
    end

    it 'raises an error if weather_description is not provided' do
      expect do
        described_class.new(
          utc: utc_time,
          temperature_apparent:
        )
      end.to raise_error(ArgumentError)
    end
  end

  describe '#utc' do
    it 'returns the correct UTC time' do
      expect(weather_snapshot.utc).to eq(utc_time)
    end
  end

  describe '#temperature_apparent' do
    it 'returns the correct apparent temperature' do
      expect(weather_snapshot.temperature_apparent).to eq(temperature_apparent)
    end
  end

  describe '#weather_description' do
    it 'returns the correct weather description' do
      expect(weather_snapshot.weather_description).to eq(weather_description)
    end
  end
end
