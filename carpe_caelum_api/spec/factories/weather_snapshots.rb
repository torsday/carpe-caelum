# frozen_string_literal: true

FactoryBot.define do
  factory :weather_snapshot do
    utc { Time.now.utc }
    temperature_apparent { Faker::Number.between(from: -20.0, to: 40.0) }
    weather_description { WeatherDescriptions.constants.sample.to_s }

    trait :with_random_weather do
      weather_description { WeatherDescriptions.constants.sample.to_s }
    end
  end
end
