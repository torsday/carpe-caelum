class WeatherSnapshotCollection
  attr_accessor :weather_snapshots

  def initialize(weather_snapshots:)
    @weather_snapshots = weather_snapshots
  end

  def get_temp_high
    weather_snapshots.values.map(&:temperature_apparent).max
  end

  def get_temp_low
    weather_snapshots.values.map(&:temperature_apparent).min
  end

  def get_utc_start
    weather_snapshots.keys.min
  end

  def get_utc_end
    weather_snapshots.keys.max
  end

  def get_list_of_snapshots
    weather_snapshots.values
  end

  def get_weather_snapshot_for(utc)
    weather_snapshots[utc]
  end
end
