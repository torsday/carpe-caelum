# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherFactory, type: :class do
  describe '.build_weather_snapshots_from_tomorrow_io_timeline_resp' do
    let(:api_response) do
      {
        'data' => {
          'timelines' => [
            {
              'intervals' => [
                {
                  'startTime' => '2024-07-12T10:00:00Z',
                  'values' => {
                    'temperatureApparent' => 25.0,
                    'weatherCode' => '1000'
                  }
                },
                {
                  'startTime' => '2024-07-12T11:00:00Z',
                  'values' => {
                    'temperatureApparent' => 26.0,
                    'weatherCode' => '1100'
                  }
                }
              ]
            }
          ]
        }
      }
    end

    it 'returns a WeatherSnapshotCollection' do
      result = described_class.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)
      expect(result).to be_a(WeatherSnapshotCollection)
    end

    it 'creates correct number of WeatherSnapshots' do
      result = described_class.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)
      expect(result.weather_snapshots.size).to eq(2)
    end

    context 'when building a WeatherSnapshot for 2024-07-12T10:00:00Z' do
      let(:snapshot) do
        result = described_class.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)
        result.weather_snapshots['2024-07-12T10:00:00Z']
      end

      it 'has correct temperature_apparent' do
        expect(snapshot.temperature_apparent).to eq(25.0)
      end

      it 'has correct weather_description' do
        expect(snapshot.weather_description).to eq(WeatherDescriptions::CLEAR_SUNNY)
      end
    end

    context 'when building a WeatherSnapshot for 2024-07-12T11:00:00Z' do
      let(:snapshot) do
        result = described_class.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)
        result.weather_snapshots['2024-07-12T11:00:00Z']
      end

      it 'has correct temperature_apparent' do
        expect(snapshot.temperature_apparent).to eq(26.0)
      end

      it 'has correct weather_description' do
        expect(snapshot.weather_description).to eq(WeatherDescriptions::MOSTLY_CLEAR)
      end
    end
  end

  describe '.build_weather_snapshot_from_tomorrow_io_timeline_interval' do
    let(:api_response_interval) do
      {
        'startTime' => '2024-07-12T10:00:00Z',
        'values' => {
          'temperatureApparent' => 25.0,
          'weatherCode' => '1000'
        }
      }
    end

    it 'returns a WeatherSnapshot' do
      result = described_class.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)
      expect(result).to be_a(WeatherSnapshot)
    end

    it 'has correct utc' do
      result = described_class.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)
      expect(result.utc).to eq(Time.parse('2024-07-12T10:00:00Z'))
    end

    it 'has correct temperature_apparent' do
      result = described_class.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)
      expect(result.temperature_apparent).to eq(25.0)
    end

    it 'has correct weather_description' do
      result = described_class.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)
      expect(result.weather_description).to eq(WeatherDescriptions::CLEAR_SUNNY)
    end
  end

  describe '.translate_tomorrow_io_weather_code_to_weather_description' do
    it 'translates weather code 1000 correctly' do
      result = described_class.send(:translate_tomorrow_io_weather_code_to_weather_description, '1000')
      expect(result).to eq(WeatherDescriptions::CLEAR_SUNNY)
    end

    it 'translates weather code 1100 correctly' do
      result = described_class.send(:translate_tomorrow_io_weather_code_to_weather_description, '1100')
      expect(result).to eq(WeatherDescriptions::MOSTLY_CLEAR)
    end

    it 'translates unknown weather code 9999 correctly' do
      result = described_class.send(:translate_tomorrow_io_weather_code_to_weather_description, '9999')
      expect(result).to eq(WeatherDescriptions::UNKNOWN)
    end
  end
end
