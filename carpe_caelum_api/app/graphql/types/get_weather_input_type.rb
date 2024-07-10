# frozen_string_literal: true

module Types
  class GetWeatherInputType < Types::BaseInputObject
    graphql_name 'GetWeatherInputType'
    argument :location, String, required: true
  end
end
