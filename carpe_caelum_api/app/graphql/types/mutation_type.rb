# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :get_weather, mutation: Mutations::GetWeather
  end
end
