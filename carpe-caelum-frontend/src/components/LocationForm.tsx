import React, { useState, useEffect } from 'react'
import { gql, useQuery } from '@apollo/client'
import styled from 'styled-components'
import 'leaflet/dist/leaflet.css'
import WeatherMap from './WeatherMap'
import ResultContainer from './ResultContainer'
import FormComponent from './FormComponent'
import { WeatherData } from '../interfaces/weatherInterfaces'
import useGeolocation from '../hooks/useGeolocation'
import useGeocodeLocation from '../hooks/useGeocodeLocation'

// GraphQL query to fetch weather data based on latitude and longitude
const GET_WEATHER = gql`
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

// Styled component for the main page container
const PageContainer = styled.div`
    background-color: #002b36;
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
`

// Styled component for the form container
const FormContainer = styled.div`
    text-align: center;
    width: 100%;
`

// Styled component for the header
const Header = styled.h1`
    color: #b58900;
    font-family: 'Luxurious Roman', serif;
    font-size: 4rem;

    @media (max-width: 768px) {
        font-size: 2rem;
    }

    @media (max-width: 480px) {
        font-size: 1.5rem;
    }
`

/**
 * LocationForm component
 * Manages the state and logic for displaying the weather information based on user's location
 */
const LocationForm: React.FC = () => {
    const [location, setLocation] = useState('')
    const [position, setPosition] = useState<[number, number] | null>(null)
    const [errorMsg, setErrorMsg] = useState('')
    const [weatherData, setWeatherData] = useState<WeatherData | null>(null)

    // Apollo Client hook to query weather data
    const { loading, refetch } = useQuery<WeatherData>(GET_WEATHER, {
        variables: { latitude: 0, longitude: 0 },
        skip: true, // Skip the query on initial load
        onError: (error) => {
            console.error('GraphQL Error:', error.message)
            setErrorMsg(error.message)
        },
    })

    // Custom hook to get the user's current geolocation
    const handleGeolocation = useGeolocation(setLocation, setPosition)

    // Custom hook to geocode the location input
    const debouncedGeocodeLocation = useGeocodeLocation(
        setPosition,
        setErrorMsg
    )

    /**
     * Handle form submission to fetch weather data
     * @param e - The form submission event
     */
    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault()
        if (position) {
            const [latitude, longitude] = position
            refetch({ latitude, longitude })
                .then((response) => {
                    setWeatherData(response.data)
                })
                .catch((err) => {
                    console.error('Error during refetch:', err)
                })
        } else {
            alert('Please select a location on the map.')
        }
    }

    // Fetch user's geolocation on component mount
    useEffect(() => {
        handleGeolocation()
    }, [handleGeolocation])

    // Refetch weather data when the position changes
    useEffect(() => {
        if (position) {
            const [latitude, longitude] = position
            refetch({ latitude, longitude })
                .then((response) => {
                    setWeatherData(response.data)
                })
                .catch((err) => {
                    console.error('Error during refetch:', err)
                })
        }
    }, [position, refetch])

    // Geocode the location whenever the location input changes
    useEffect(() => {
        if (location) {
            debouncedGeocodeLocation(location)
        }
    }, [location, debouncedGeocodeLocation])

    return (
        <PageContainer>
            <FormContainer>
                <Header>CARPE CAELUM</Header>
                <WeatherMap
                    position={position}
                    setPosition={setPosition}
                    LAT_LON_PRECISION={6}
                    getWeather={refetch}
                />
                <FormComponent
                    location={location}
                    setLocation={setLocation}
                    handleGeolocation={handleGeolocation}
                    handleSubmit={handleSubmit}
                />
                {loading && <p>Loading...</p>}
                {errorMsg && <p>Error: {errorMsg}</p>}
                {weatherData && weatherData.weather && (
                    <ResultContainer weatherData={weatherData} />
                )}
            </FormContainer>
        </PageContainer>
    )
}

export default LocationForm
