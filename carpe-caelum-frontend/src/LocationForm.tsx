import React, { useState, useEffect, useCallback } from 'react';
import { gql, useMutation } from '@apollo/client';
import styled from 'styled-components';
import debounce from 'lodash.debounce';
import 'leaflet/dist/leaflet.css';
import WeatherMap from './WeatherMap'; // Import the new component

const GET_WEATHER = gql`
  mutation GetWeather($input: GetWeatherInput!) {
    getWeather(input: $input) {
      temperature
      description
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
  font-size: 4rem; /* Large header size */

  @media (max-width: 768px) {
    font-size: 2rem; /* Adjust for tablets */
  }

  @media (max-width: 480px) {
    font-size: 1.5rem; /* Adjust for mobile phones */
  }
`;

// 6 gives us a precision of 3.6 feet.
// The backend can choose to use that precision, or lower it, but I'm confident it won't need more.
const LAT_LON_PRECISION = 6;

const DEBOUNCE_DELAY = 1000; // The time to wait before geocoding the location.

const LocationForm: React.FC = () => {
  const [location, setLocation] = useState('');
  const [position, setPosition] = useState<[number, number] | null>(null);
  const [errorMsg, setErrorMsg] = useState('');
  const [getWeather, { data, loading, error }] = useMutation(GET_WEATHER, {
    onError: (error) => {
      setErrorMsg(error.message);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (position) {
      const [lat, lon] = position.map((coord) => coord.toFixed(LAT_LON_PRECISION));
      getWeather({ variables: { input: { input: { location: `${lat},${lon}` } } } });
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
          setLocation(`${lat},${lon}`);
          setPosition([parseFloat(lat), parseFloat(lon)]);
          getWeather({ variables: { input: { input: { location: `${lat},${lon}` } } } });
        },
        (error) => {
          console.error("Error fetching geolocation:", error);
          alert("Unable to fetch your location.");
        }
      );
    } else {
      alert("Geolocation is not supported by this browser.");
    }
  }, [getWeather]);

  useEffect(() => {
    // Automatically try to ascertain the user's location on page load
    handleGeolocation();
  }, [handleGeolocation]);

  const geocodeLocation = async (location: string) => {
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(location)}`
      );
      const data = await response.json();

      if (data.length > 0) {
        const { lat, lon } = data[0];
        setPosition([parseFloat(lat), parseFloat(lon)]);
        getWeather({ variables: { input: { input: { location: `${lat},${lon}` } } } });
      } else {
        console.warn('Location not found.');
      }
    } catch (error) {
      console.error("Error geocoding location:", error);
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
          getWeather={getWeather}
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
        {data && (
          <ResultContainer>
            <p>Temperature: {data.getWeather.temperature}°F</p>
            <p>Description: {data.getWeather.description}</p>
          </ResultContainer>
        )}
      </FormContainer>
    </PageContainer>
  );
};

export default LocationForm;
