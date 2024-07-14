/**
 * Interface representing the structure of weather data.
 */
export interface WeatherData {
    weather: {
        /**
         * The current temperature in degrees Fahrenheit.
         */
        temperature: number

        /**
         * The lowest temperature expected in the next five hours in degrees Fahrenheit.
         */
        fiveHrTemperatureLow: number

        /**
         * The highest temperature expected in the next five hours in degrees Fahrenheit.
         */
        fiveHrTemperatureHigh: number

        /**
         * A description of the current weather conditions.
         */
        description: string

        /**
         * An error message if there was an issue fetching the weather data.
         */
        errorMessage: string
    }
}
