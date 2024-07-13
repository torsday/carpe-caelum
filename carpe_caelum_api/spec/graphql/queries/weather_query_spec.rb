# frozen_string_literal: true

# spec/graphql/queries/weather_query_spec.rb

require 'rails_helper'

RSpec.describe Queries::WeatherQuery, type: :request do
  describe '.resolve' do
    let(:latitude) { 45.0 }
    let(:longitude) { -93.0 }
    let(:weather_service) { instance_double(WeatherService) }
    let(:current_temperature) { 75.0 }
    let(:low_temperature) { 65.0 }
    let(:high_temperature) { 85.0 }
    let(:description) { 'Clear sky' }

    before do
      allow(WeatherService).to receive(:new).and_return(weather_service)
      allow(weather_service).to receive(:get_current_feels_like_temperature_for).with(latitude:,
                                                                                      longitude:).and_return(current_temperature)
      allow(weather_service).to receive(:get_5_hr_temperature_low_for).with(latitude:,
                                                                            longitude:).and_return(low_temperature)
      allow(weather_service).to receive(:get_5_hr_temperature_high_for).with(latitude:,
                                                                             longitude:).and_return(high_temperature)
      allow(weather_service).to receive(:get_current_conditions_for).with(latitude:,
                                                                          longitude:).and_return(description)
    end

    context 'when the query is successful' do
      it 'returns the weather data' do
        post '/graphql', params: { query: weather_query(latitude, longitude) }

        json = JSON.parse(response.body)
        data = json['data']['weather']

        expect(data).to include(
          'temperature' => current_temperature,
          'fiveHrTemperatureLow' => low_temperature,
          'fiveHrTemperatureHigh' => high_temperature,
          'description' => description,
          'errorMessage' => nil
        )
      end
    end

    context 'when an error occurs' do
      let(:error_message) { 'An error occurred' }

      before do
        allow(weather_service).to receive(:get_current_feels_like_temperature_for).and_raise(StandardError,
                                                                                             error_message)
      end

      it 'returns an error message' do
        post '/graphql', params: { query: weather_query(latitude, longitude) }

        json = JSON.parse(response.body)
        data = json['data']['weather']

        expect(data).to include(
          'temperature' => nil,
          'fiveHrTemperatureLow' => nil,
          'fiveHrTemperatureHigh' => nil,
          'description' => nil,
          'errorMessage' => error_message
        )
      end
    end
  end

  def weather_query(latitude, longitude)
    <<~GQL
      query {
        weather(latitude: #{latitude}, longitude: #{longitude}) {
          temperature
          fiveHrTemperatureLow
          fiveHrTemperatureHigh
          description
          errorMessage
        }
      }
    GQL
  end
end
