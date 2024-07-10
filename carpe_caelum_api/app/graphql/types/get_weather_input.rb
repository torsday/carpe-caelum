# frozen_string_literal: true

module Types
  class GetWeatherInput < Types::BaseInputObject
    graphql_name 'GetWeatherInput'
    argument :input, Types::GetWeatherInputType, required: true
  end
end
