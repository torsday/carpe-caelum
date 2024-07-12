import React, { useState, useEffect, useCallback } from 'react';
import { gql, useQuery } from '@apollo/client';
import styled from 'styled-components';
import debounce from 'lodash.debounce';
import axios from 'axios';
import 'leaflet/dist/leaflet.css';
import WeatherMap from './WeatherMap';

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
`;

const PageContainer = styled.div`
    background-color: #002b36;
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
`;

const FormContainer = styled.div`
    text-align: center;
    width: 100%;
`;

const Form = styled.form`
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: 16px;
`;

const InputContainer = styled.div`
    display: flex;
    align-items: center;
    margin-top: 16px;
`;

const Input = styled.input`
    padding: 8px;
    font-size: 16px;
    flex: 1;
`;

const Button = styled.button`
    padding: 8px 16px;
    font-size: 16px;
    cursor: pointer;
    border: none;
    margin-top: 8px;
    background-color: ${(props) => (props.type === 'submit' ? '#28A745' : '#007BFF')};
    color: white;

    &:hover {
        opacity: 0.8;
    }

    &:not(:last-child) {
        margin-left: 8px;
    }
`;

const ResultContainer = styled.div`
    margin-top: 16px;
`;

const Header = styled.h1`
    color: #b58900;
    font-family: "Luxurious Roman", serif;
    font-size: 4rem;

    @media (max-width: 768px) {
        font-size: 2rem;
    }

    @media (max-width: 480px) {
        font-size: 1.5rem;
    }
`;

const LAT_LON_PRECISION = 6;
const DEBOUNCE_DELAY = 1000;

const LocationForm: React.FC = () => {
    const [location, setLocation] = useState('');
    const [position, setPosition] = useState<[number, number] | null>(null);
    const [errorMsg, setErrorMsg] = useState('');
    const [weatherData, setWeatherData] = useState(null);

    const { data, loading, error, refetch } = useQuery(GET_WEATHER, {
        variables: { latitude: 0, longitude: 0 },
        skip: true,
        onError: (error) => {
            console.error("GraphQL Error:", error.message);
            setErrorMsg(error.message);
        },
    });

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (position) {
            const [latitude, longitude] = position;
            console.log("Fetching weather for position:", { latitude, longitude });
            refetch({ latitude, longitude })
                .then((response) => {
                    console.log("Refetch response: ", response.data);
                    setWeatherData(response.data);
                })
                .catch((err) => {
                    console.error("Error during refetch: ", err);
                });
        } else {
            alert("Please select a location on the map.");
        }
    };

    const handleGeolocation = useCallback(() => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const lat = position.coords.latitude.toFixed(LAT_LON_PRECISION);
                    const lon = position.coords.longitude.toFixed(LAT_LON_PRECISION);
                    console.log("Geolocation position:", { lat, lon });
                    setLocation(`${lat},${lon}`);
                    setPosition([parseFloat(lat), parseFloat(lon)]);
                },
                (error) => {
                    console.error("Error fetching geolocation:", error);
                    alert("Unable to fetch your location.");
                }
            );
        } else {
            alert("Geolocation is not supported by this browser.");
        }
    }, []);

    useEffect(() => {
        handleGeolocation();
    }, [handleGeolocation]);

    useEffect(() => {
        if (position) {
            const [latitude, longitude] = position;
            console.log("Refetching weather for position:", { latitude, longitude });
            refetch({ latitude, longitude })
                .then((response) => {
                    console.log("Refetch response: ", response.data);
                    setWeatherData(response.data);
                })
                .catch((err) => {
                    console.error("Error during refetch: ", err);
                });
        }
    }, [position, refetch]);

    const geocodeLocation = async (location: string) => {
        try {
            const response = await axios.get(
                `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(location)}.json`,
                {
                    params: {
                        access_token: process.env.MAPBOX_API_TOKEN,
                    },
                }
            );
            const data = response.data;

            if (data.features && data.features.length > 0) {
                const { center } = data.features[0];
                const [lon, lat] = center;
                console.log("Geocoded position:", { lat, lon });
                setPosition([lat, lon]);
            } else {
                console.warn('Location not found.');
            }
        } catch (error) {
            console.error("Error geocoding location:", error);
            setErrorMsg("Error geocoding location. Please try again.");
        }
    };

    const debouncedGeocodeLocation = useCallback(debounce(geocodeLocation, DEBOUNCE_DELAY), []);

    useEffect(() => {
        if (location) {
            debouncedGeocodeLocation(location);
        }
    }, [location, debouncedGeocodeLocation]);

    return (
        <PageContainer>
            <FormContainer>
                <Header>CARPE CAELUM</Header>
                <WeatherMap
                    position={position}
                    setPosition={setPosition}
                    LAT_LON_PRECISION={LAT_LON_PRECISION}
                    refetchWeather={refetch}
                />
                <Form onSubmit={handleSubmit}>
                    <InputContainer>
                        <Input
                            type="text"
                            value={location}
                            onChange={(e) => setLocation(e.target.value)}
                            placeholder="Enter location"
                        />
                        <Button type="button" onClick={handleGeolocation}>
                            Use My Location
                        </Button>
                    </InputContainer>
                    <Button type="submit">Get Weather</Button>
                </Form>
                {loading && <p>Loading...</p>}
                {errorMsg && <p>Error: {errorMsg}</p>}
                {weatherData && weatherData.weather && (
                    <ResultContainer>
                        <p>5 Hour Forecast (Low &lt; Present &lt; High) in °F</p>
                        <p>
                            {weatherData.weather.fiveHrTemperatureLow}°F &lt; {weatherData.weather.temperature}°F &lt; {weatherData.weather.fiveHrTemperatureHigh}°F
                        </p>                        
                        {weatherData.weather.description && (
                            <p>{weatherData.weather.description}</p>
                        )}
                        {weatherData.weather.errorMessage && <p>Error: {weatherData.weather.errorMessage}</p>}
                    </ResultContainer>
                )}
            </FormContainer>
        </PageContainer>
    );
};

export default LocationForm;
