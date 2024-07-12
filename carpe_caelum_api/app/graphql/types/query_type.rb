# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :weather, resolver: Queries::WeatherQuery
  end
end
