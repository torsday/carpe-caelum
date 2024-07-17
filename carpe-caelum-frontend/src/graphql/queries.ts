// src/graphql/queries.ts
import { gql } from '@apollo/client'

export const GET_WEATHER = gql`
    query GetWeather($latitude: Float!, $longitude: Float!) {
        weather(latitude: $latitude, longitude: $longitude) {
            temperature
            fiveHrTemperatureLow
            fiveHrTemperatureHigh
            description
            errorMessage
        }
    }
`
