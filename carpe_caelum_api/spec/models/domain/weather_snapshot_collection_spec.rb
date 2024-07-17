# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../app/models/domain/weather_snapshot_collection'
require_relative '../../../app/models/domain/weather_snapshot'

RSpec.describe WeatherSnapshotCollection do
  let(:snapshot_sunny) do
    WeatherSnapshot.new(utc: '2023-07-03T12:00:00Z', temperature_apparent: 75.0, weather_description: 'Sunny')
  end
  let(:snapshot_partly_cloudy) do
    WeatherSnapshot.new(utc: '2023-07-03T13:00:00Z', temperature_apparent: 80.0, weather_description: 'Partly Cloudy')
  end
  let(:snapshot_cloudy) do
    WeatherSnapshot.new(utc: '2023-07-03T14:00:00Z', temperature_apparent: 70.0, weather_description: 'Cloudy')
  end
  let(:snapshots) do
    {
      '2023-07-03T12:00:00Z' => snapshot_sunny,
      '2023-07-03T13:00:00Z' => snapshot_partly_cloudy,
      '2023-07-03T14:00:00Z' => snapshot_cloudy
    }
  end
  let(:collection) { described_class.new(weather_snapshots: snapshots) }

  describe '#initialize' do
    it 'creates an instance of WeatherSnapshotCollection with correct attributes' do
      expect(collection.weather_snapshots).to eq(snapshots)
    end
  end

  describe '#temp_high' do
    it 'returns the highest apparent temperature' do
      expect(collection.temp_high).to eq(80.0)
    end
  end

  describe '#temp_low' do
    it 'returns the lowest apparent temperature' do
      expect(collection.temp_low).to eq(70.0)
    end
  end

  describe '#utc_start' do
    it 'returns the earliest UTC timestamp' do
      expect(collection.utc_start).to eq('2023-07-03T12:00:00Z')
    end
  end

  describe '#utc_end' do
    it 'returns the latest UTC timestamp' do
      expect(collection.utc_end).to eq('2023-07-03T14:00:00Z')
    end
  end

  describe '#list_of_snapshots' do
    it 'returns a list of all weather snapshots' do
      expect(collection.list_of_snapshots).to contain_exactly(snapshot_sunny, snapshot_partly_cloudy, snapshot_cloudy)
    end
  end

  describe '#weather_snapshot_for' do
    it 'returns the weather snapshot for a given UTC' do
      expect(collection.weather_snapshot_for('2023-07-03T12:00:00Z')).to eq(snapshot_sunny)
      expect(collection.weather_snapshot_for('2023-07-03T13:00:00Z')).to eq(snapshot_partly_cloudy)
      expect(collection.weather_snapshot_for('2023-07-03T14:00:00Z')).to eq(snapshot_cloudy)
    end

    it 'returns nil if no snapshot exists for the given UTC' do
      expect(collection.weather_snapshot_for('2023-07-03T15:00:00Z')).to be_nil
    end
  end
end
