export interface WeatherData {
    weather: {
        temperature: number
        fiveHrTemperatureLow: number
        fiveHrTemperatureHigh: number
        description: string
        errorMessage: string
    }
}
