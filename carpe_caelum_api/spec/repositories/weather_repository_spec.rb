# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherRepository do
  let(:redis_client) { instance_double(Redis) }
  let(:tomorrow_io_wrapper) { instance_double(TomorrowIoApi) }
  let(:latitude_longitude_precision) { 3 }
  let(:weather_repository) do
    described_class.new(
      redis_client:,
      tomorrow_io_wrapper:,
      latitude_longitude_precision:
    )
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

  describe '#current_feels_like_temperature_for' do
    let(:latitude) { 45.0 }
    let(:longitude) { -122.0 }
    let(:weather_snapshot) { instance_double(WeatherSnapshot, temperature_apparent: 72.5) }

    before do
      allow(weather_repository).to receive_messages(snapshot_for: weather_snapshot,
                                                    current_utc_rounded_down: Time.now.utc.change(
                                                      min: 0, sec: 0
                                                    ))
    end

    it 'returns the current feels like temperature' do
      expect(weather_repository.current_feels_like_temperature_for(latitude:,
                                                                   longitude:)).to eq(72.5)
    end
  end

  describe '#current_conditions_for' do
    let(:latitude) { 45.0 }
    let(:longitude) { -122.0 }
    let(:weather_snapshot) { instance_double(WeatherSnapshot, weather_description: 'Sunny') }

    before do
      allow(weather_repository).to receive_messages(snapshot_for: weather_snapshot,
                                                    current_utc_rounded_down: Time.now.utc.change(
                                                      min: 0, sec: 0
                                                    ))
    end

    it 'returns the current weather conditions' do
      expect(weather_repository.current_conditions_for(latitude:, longitude:)).to eq('Sunny')
    end
  end

  describe '#feels_like_high_and_low_for' do
    let(:latitude) { 45.0 }
    let(:longitude) { -122.0 }
    let(:window_in_hours) { 6 }
    let(:snapshot_collection) { instance_double(WeatherSnapshotCollection, temp_low: 65.0, temp_high: 85.0) }

    before do
      allow(weather_repository).to receive(:build_snapshot_collection).and_return(snapshot_collection)
    end

    it 'returns the high and low feels like temperatures' do
      result = weather_repository.feels_like_high_and_low_for(latitude:, longitude:,
                                                              window_in_hours:)
      expect(result).to eq({ temp_low: 65.0, temp_high: 85.0 })
    end
  end

  describe '#validate_coordinates' do
    it 'raises an error if latitude is out of range' do
      expect do
        weather_repository.send(:validate_coordinates, -100,
                                0)
      end.to raise_error(ArgumentError, 'latitude must be between -90 and 90')
    end

    it 'raises an error if longitude is out of range' do
      expect do
        weather_repository.send(:validate_coordinates, 0,
                                -200)
      end.to raise_error(ArgumentError, 'longitude must be between -180 and 180')
    end
  end

  describe '#validate_utc' do
    it 'raises an error if utc is not a Time object' do
      expect do
        weather_repository.send(:validate_utc, 'not a time')
      end.to raise_error(ArgumentError, 'utc must be a Time object')
    end
  end

  describe '#validate_window_in_hours' do
    it 'raises an error if window_in_hours is not a positive integer' do
      expect do
        weather_repository.send(:validate_window_in_hours,
                                -1)
      end.to raise_error(ArgumentError, 'window_in_hours must be a positive integer')
    end
  end
end
