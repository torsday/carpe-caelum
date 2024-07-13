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

    it 'builds a WeatherSnapshotCollection from the API response' do
      result = described_class.build_weather_snapshots_from_tomorrow_io_timeline_resp(api_response)

      expect(result).to be_a(WeatherSnapshotCollection)
      expect(result.weather_snapshots.size).to eq(2)
      expect(result.weather_snapshots['2024-07-12T10:00:00Z'].temperature_apparent).to eq(25.0)
      expect(result.weather_snapshots['2024-07-12T10:00:00Z'].weather_description).to eq(WeatherDescriptions::CLEAR_SUNNY)
      expect(result.weather_snapshots['2024-07-12T11:00:00Z'].temperature_apparent).to eq(26.0)
      expect(result.weather_snapshots['2024-07-12T11:00:00Z'].weather_description).to eq(WeatherDescriptions::MOSTLY_CLEAR)
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

    it 'builds a WeatherSnapshot from a single interval' do
      result = described_class.build_weather_snapshot_from_tomorrow_io_timeline_interval(api_response_interval:)

      expect(result).to be_a(WeatherSnapshot)
      expect(result.utc).to eq(Time.parse('2024-07-12T10:00:00Z'))
      expect(result.temperature_apparent).to eq(25.0)
      expect(result.weather_description).to eq(WeatherDescriptions::CLEAR_SUNNY)
    end
  end

  describe '.translate_tomorrow_io_weather_code_to_weather_description' do
    it 'translates weather codes correctly' do
      expect(described_class.send(:translate_tomorrow_io_weather_code_to_weather_description,
                                  '1000')).to eq(WeatherDescriptions::CLEAR_SUNNY)
      expect(described_class.send(:translate_tomorrow_io_weather_code_to_weather_description,
                                  '1100')).to eq(WeatherDescriptions::MOSTLY_CLEAR)
      expect(described_class.send(:translate_tomorrow_io_weather_code_to_weather_description,
                                  '9999')).to eq(WeatherDescriptions::UNKNOWN)
    end
  end
end
