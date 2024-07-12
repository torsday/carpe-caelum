require 'rails_helper'
require_relative '../../app/models/domain/weather_snapshot_collection'
require_relative '../../app/models/domain/weather_snapshot'


RSpec.describe WeatherSnapshotCollection do
  let(:snapshot1) { WeatherSnapshot.new(utc: '2023-07-03T12:00:00Z', temperature_apparent: 75.0, weather_description: 'Sunny') }
  let(:snapshot2) { WeatherSnapshot.new(utc: '2023-07-03T13:00:00Z', temperature_apparent: 80.0, weather_description: 'Partly Cloudy') }
  let(:snapshot3) { WeatherSnapshot.new(utc: '2023-07-03T14:00:00Z', temperature_apparent: 70.0, weather_description: 'Cloudy') }
  let(:snapshots) do
    {
      '2023-07-03T12:00:00Z' => snapshot1,
      '2023-07-03T13:00:00Z' => snapshot2,
      '2023-07-03T14:00:00Z' => snapshot3
    }
  end
  let(:collection) { WeatherSnapshotCollection.new(weather_snapshots: snapshots) }

  describe '#initialize' do
    it 'creates an instance of WeatherSnapshotCollection with correct attributes' do
      expect(collection.weather_snapshots).to eq(snapshots)
    end
  end

  describe '#get_temp_high' do
    it 'returns the highest apparent temperature' do
      expect(collection.get_temp_high).to eq(80.0)
    end
  end

  describe '#get_temp_low' do
    it 'returns the lowest apparent temperature' do
      expect(collection.get_temp_low).to eq(70.0)
    end
  end

  describe '#get_utc_start' do
    it 'returns the earliest UTC timestamp' do
      expect(collection.get_utc_start).to eq('2023-07-03T12:00:00Z')
    end
  end

  describe '#get_utc_end' do
    it 'returns the latest UTC timestamp' do
      expect(collection.get_utc_end).to eq('2023-07-03T14:00:00Z')
    end
  end

  describe '#get_list_of_snapshots' do
    it 'returns a list of all weather snapshots' do
      expect(collection.get_list_of_snapshots).to contain_exactly(snapshot1, snapshot2, snapshot3)
    end
  end

  describe '#get_weather_snapshot_for' do
    it 'returns the weather snapshot for a given UTC' do
      expect(collection.get_weather_snapshot_for('2023-07-03T12:00:00Z')).to eq(snapshot1)
      expect(collection.get_weather_snapshot_for('2023-07-03T13:00:00Z')).to eq(snapshot2)
      expect(collection.get_weather_snapshot_for('2023-07-03T14:00:00Z')).to eq(snapshot3)
    end

    it 'returns nil if no snapshot exists for the given UTC' do
      expect(collection.get_weather_snapshot_for('2023-07-03T15:00:00Z')).to be_nil
    end
  end
end
