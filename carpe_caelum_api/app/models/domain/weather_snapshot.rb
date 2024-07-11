class WeatherSnapshot
  attr_accessor :utc, :temperature_apparent, :weather_description

  def initialize(utc:, temperature_apparent:, weather_description:)
    @utc = utc
    @temperature_apparent = temperature_apparent
    @weather_description = weather_description
  end

end
