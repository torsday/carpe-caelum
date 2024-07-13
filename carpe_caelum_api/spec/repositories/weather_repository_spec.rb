# frozen_string_literal: true

# spec/weather_repository_spec.rb
require 'rails_helper'

require_relative '../../app/repositories/weather_repository'
require_relative '../../app/models/domain/weather_snapshot_collection'
require_relative '../../app/models/domain/weather_snapshot'

RSpec.describe WeatherRepository do
  let(:redis_client) { double('RedisClient') }
  let(:tomorrow_io_wrapper) { double('TomorrowIoWrapper') }
  let(:latitude_longitude_precision) { 2 }
  let(:repository) do
    described_class.new(redis_client:, tomorrow_io_wrapper:, latitude_longitude_precision:)
  end

  describe '#initialize' do
    it 'raises an error if redis_client is nil' do
      expect do
        described_class.new(redis_client: nil, tomorrow_io_wrapper:,
                            latitude_longitude_precision:)
      end.to raise_error(ArgumentError, 'redis_client cannot be nil')
    end

    it 'raises an error if tomorrow_io_wrapper is nil' do
      expect do
        described_class.new(redis_client:, tomorrow_io_wrapper: nil,
                            latitude_longitude_precision:)
      end.to raise_error(ArgumentError, 'tomorrow_io_wrapper cannot be nil')
    end

    it 'raises an error if latitude_longitude_precision is not a non-negative integer' do
      expect do
        described_class.new(redis_client:, tomorrow_io_wrapper:,
                            latitude_longitude_precision: -1)
      end.to raise_error(ArgumentError, 'latitude_longitude_precision must be a non-negative integer')
    end
  end

  describe '#get_current_feels_like_temperature_for' do
    it 'returns the current feels like temperature' do
      latitude = 45.0
      longitude = -122.0
      utc = Time.now.utc.change(min: 0, sec: 0)
      snapshot = WeatherSnapshot.new(utc:, temperature_apparent: 75.0, weather_description: 'Sunny')

      allow(repository).to receive(:get_snapshot_for).with(latitude:, longitude:,
                                                           utc:).and_return(snapshot)

      expect(repository.get_current_feels_like_temperature_for(latitude:, longitude:)).to eq(75.0)
    end
  end

  describe '#get_current_conditions_for' do
    it 'returns the current weather conditions' do
      latitude = 45.0
      longitude = -122.0
      utc = Time.now.utc.change(min: 0, sec: 0)
      snapshot = WeatherSnapshot.new(utc:, temperature_apparent: 75.0, weather_description: 'Sunny')

      allow(repository).to receive(:get_snapshot_for).with(latitude:, longitude:,
                                                           utc:).and_return(snapshot)

      expect(repository.get_current_conditions_for(latitude:, longitude:)).to eq('Sunny')
    end
  end
end
