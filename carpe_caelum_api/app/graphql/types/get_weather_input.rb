# frozen_string_literal: true

module Types
  # GetWeatherInput is the input object type for retrieving weather data.
  class GetWeatherInput < Types::BaseInputObject
    description 'Input object type for retrieving weather data'

    # The input for getting weather data.
    argument :input, Types::GetWeatherInputType, required: true, description: 'The input for getting weather data'
  end
end
