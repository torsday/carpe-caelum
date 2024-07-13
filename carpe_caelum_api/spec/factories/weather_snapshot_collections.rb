# frozen_string_literal: true

FactoryBot.define do
  factory :weather_snapshot_collection do
    transient do
      snapshots_count { 5 }
    end

    weather_snapshots do
      snapshots = {}
      snapshots_count.times do |_i|
        snapshot = build(:weather_snapshot)
        snapshots[snapshot.utc] = snapshot
      end
      snapshots
    end

    initialize_with { new(weather_snapshots:) }
  end
end
