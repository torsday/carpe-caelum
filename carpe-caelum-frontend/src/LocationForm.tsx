import React, { useState, useEffect, useCallback } from 'react';
import { gql, useMutation } from '@apollo/client';
import { MapContainer, TileLayer, Marker, useMapEvents, useMap } from 'react-leaflet';
import styled from 'styled-components';
import debounce from 'lodash.debounce';
import 'leaflet/dist/leaflet.css';

const GET_WEATHER = gql`
  mutation GetWeather($input: GetWeatherInput!) {
    getWeather(input: $input) {
      temperature
      description
    }
  }
`;

const FormContainer = styled.div`
  text-align: center;
`;

const Form = styled.form`
  display: inline-block;
  text-align: left;
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

const MapContainerStyled = styled(MapContainer)`
  height: 400px;
  width: 100%;
  margin-top: 16px;
`;

const LocationForm: React.FC = () => {
  const [location, setLocation] = useState('');
  const [position, setPosition] = useState<[number, number] | null>(null);
  const [getWeather, { data, loading, error }] = useMutation(GET_WEATHER);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    getWeather({ variables: { input: { input: { location }} } });
  };

  const handleGeolocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lon = position.coords.longitude;
          setLocation(`${lat},${lon}`);
          setPosition([lat, lon]);
        },
        (error) => {
          console.error("Error fetching geolocation:", error);
          alert("Unable to fetch your location.");
        }
      );
    } else {
      alert("Geolocation is not supported by this browser.");
    }
  };

  const geocodeLocation = async (location: string) => {
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(location)}`
      );
      const data = await response.json();

      if (data.length > 0) {
        const { lat, lon } = data[0];
        setPosition([parseFloat(lat), parseFloat(lon)]);
      } else {
        console.warn('Location not found.');
      }
    } catch (error) {
      console.error("Error geocoding location:", error);
    }
  };

  const debouncedGeocodeLocation = useCallback(debounce(geocodeLocation, 500), []);

  useEffect(() => {
    if (location) {
      debouncedGeocodeLocation(location);
    }
  }, [location, debouncedGeocodeLocation]);

  const LocationMarker = () => {
    const map = useMap();

    useEffect(() => {
      if (position) {
        map.setView(position, map.getZoom());
      }
    }, [position, map]);

    useMapEvents({
      click(e) {
        setPosition([e.latlng.lat, e.latlng.lng]);
        setLocation(`${e.latlng.lat},${e.latlng.lng}`);
      },
    });

    return position === null ? null : <Marker position={position}></Marker>;
  };

  return (
    <FormContainer>
      <h1>Weather Finder</h1>
      <MapContainerStyled center={position || [45.5348, -122.6975]} zoom={13}>
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        />
        <LocationMarker />
      </MapContainerStyled>
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
      {error && <p>Error: {error.message}</p>}
      {data && (
        <ResultContainer>
          <p>Temperature: {data.getWeather.temperature}°C</p>
          <p>Description: {data.getWeather.description}</p>
        </ResultContainer>
      )}
    </FormContainer>
  );
};

export default LocationForm;
