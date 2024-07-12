require 'rails_helper'

RSpec.describe WeatherService do
  let(:weather_repository) { double('WeatherRepository') }
  let(:service) { WeatherService.new(weather_repository: weather_repository) }

  describe '#get_current_feels_like_temperature_for' do
    it 'returns the current feels like temperature for given coordinates' do
      latitude = 45.0
      longitude = -122.0
      temperature_apparent = 75.0

      allow(weather_repository).to receive(:get_current_feels_like_temperature_for)
                                    .with(latitude: latitude, longitude: longitude)
                                    .and_return(temperature_apparent)

      result = service.get_current_feels_like_temperature_for(latitude: latitude, longitude: longitude)

      expect(result).to eq(temperature_apparent)
    end
  end

  describe '#get_5_hr_temperature_low_for' do
    it 'returns the lowest feels like temperature for the next 5 hours' do
      latitude = 45.0
      longitude = -122.0
      temp_low = 65.0

      allow(weather_repository).to receive(:get_feels_like_high_and_low_for)
                                    .with(latitude, longitude, 5)
                                    .and_return({ temp_low: temp_low, temp_high: 85.0 })

      result = service.get_5_hr_temperature_low_for(latitude: latitude, longitude: longitude)

      expect(result).to eq(temp_low)
    end
  end

  describe '#get_5_hr_temperature_high_for' do
    it 'returns the highest feels like temperature for the next 5 hours' do
      latitude = 45.0
      longitude = -122.0
      temp_high = 85.0

      allow(weather_repository).to receive(:get_feels_like_high_and_low_for)
                                    .with(latitude, longitude, 5)
                                    .and_return({ temp_low: 65.0, temp_high: temp_high })

      result = service.get_5_hr_temperature_high_for(latitude: latitude, longitude: longitude)

      expect(result).to eq(temp_high)
    end
  end

  describe '#get_feels_like_high_and_low_for' do
    it 'returns the high and low feels like temperatures for a given window' do
      latitude = 45.0
      longitude = -122.0
      window_in_hours = 24
      temp_low = 55.0
      temp_high = 95.0

      allow(weather_repository).to receive(:get_feels_like_high_and_low_for)
                                    .with(latitude, longitude, window_in_hours)
                                    .and_return({ temp_low: temp_low, temp_high: temp_high })

      result = service.get_feels_like_high_and_low_for(latitude: latitude, longitude: longitude, window_in_hours: window_in_hours)

      expect(result[:temp_low]).to eq(temp_low)
      expect(result[:temp_high]).to eq(temp_high)
    end
  end

  describe '#get_current_conditions_for' do
    it 'returns the current weather conditions for given coordinates' do
      latitude = 45.0
      longitude = -122.0
      conditions = 'Sunny'

      allow(weather_repository).to receive(:get_current_conditions_for)
                                    .with(latitude: latitude, longitude: longitude)
                                    .and_return(conditions)

      result = service.get_current_conditions_for(latitude: latitude, longitude: longitude)

      expect(result).to eq(conditions)
    end
  end
end
