# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:weather_repository) { instance_double(WeatherRepository) }
  let(:weather_service) { described_class.new(weather_repository:) }

  describe '#get_current_feels_like_temperature_for' do
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }
    let(:temperature) { 25.0 }

    it 'returns the current feels like temperature' do
      allow(weather_repository).to receive(:current_feels_like_temperature_for)
        .with(latitude:, longitude:)
        .and_return(temperature)

      result = weather_service.get_current_feels_like_temperature_for(latitude:, longitude:)
      expect(result).to eq(temperature)
    end
  end

  describe '#get_5_hr_temperature_low_for' do
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }
    let(:temp_low) { 15.0 }

    it 'returns the low feels like temperature for the next 5 hours' do
      allow(weather_service).to receive(:get_feels_like_high_and_low_for)
        .with(latitude:, longitude:, window_in_hours: 5)
        .and_return({ temp_low:, temp_high: 30.0 })

      result = weather_service.get_5_hr_temperature_low_for(latitude:, longitude:)
      expect(result).to eq(temp_low)
    end
  end

  describe '#get_5_hr_temperature_high_for' do
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }
    let(:temp_high) { 30.0 }

    it 'returns the high feels like temperature for the next 5 hours' do
      allow(weather_service).to receive(:get_feels_like_high_and_low_for)
        .with(latitude:, longitude:, window_in_hours: 5)
        .and_return({ temp_low: 15.0, temp_high: })

      result = weather_service.get_5_hr_temperature_high_for(latitude:, longitude:)
      expect(result).to eq(temp_high)
    end
  end

  describe '#get_feels_like_high_and_low_for' do
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }
    let(:window_in_hours) { 24 }
    let(:high_and_low) { { temp_low: 15.0, temp_high: 30.0 } }

    it 'returns the high and low feels like temperatures for the given time window' do
      allow(weather_repository).to receive(:feels_like_high_and_low_for)
        .with(latitude:, longitude:, window_in_hours:)
        .and_return(high_and_low)

      result = weather_service.get_feels_like_high_and_low_for(latitude:, longitude:, window_in_hours:)
      expect(result).to eq(high_and_low)
    end
  end

  describe '#get_current_conditions_for' do
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }
    let(:conditions) { 'Sunny' }

    it 'returns the current weather conditions' do
      allow(weather_repository).to receive(:current_conditions_for)
        .with(latitude:, longitude:)
        .and_return(conditions)

      result = weather_service.get_current_conditions_for(latitude:, longitude:)
      expect(result).to eq(conditions)
    end
  end
end
