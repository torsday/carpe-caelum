# frozen_string_literal: true

module Types
  # Input type for fetching weather information
  class GetWeatherInputType < Types::BaseInputObject
    graphql_name 'GetWeatherInputType'

    description 'Input type containing location information for fetching weather details'

    argument :location, String, required: true, description: 'The location for which to fetch the weather information'
  end
end
