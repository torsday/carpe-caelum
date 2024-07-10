import React, { useState, useEffect, useCallback, useRef } from 'react';
import { gql, useMutation } from '@apollo/client';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import styled from 'styled-components';
import debounce from 'lodash.debounce';
import 'leaflet/dist/leaflet.css';
import { Map as LeafletMap } from 'leaflet';

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

const MapContainerStyled = styled(MapContainer)`
  height: 400px;
  width: 100%;
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

const LocationForm: React.FC = () => {
  const [location, setLocation] = useState('');
  const [position, setPosition] = useState<[number, number] | null>(null);
  const [getWeather, { data, loading, error }] = useMutation(GET_WEATHER);
  const mapRef = useRef<LeafletMap>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (position) {
      const [lat, lon] = position.map((coord) => coord.toFixed(6)); // Limit to 6 digits
      getWeather({ variables: { input: { input: { location: `${lat},${lon}` } } } });
    } else {
      alert("Please select a location on the map.");
    }
  };

  const handleGeolocation = () => {
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
  };

  useEffect(() => {
    // Automatically try to ascertain the user's location on page load
    handleGeolocation();
  }, []);

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

  const debouncedGeocodeLocation = useCallback(debounce(geocodeLocation, 500), []);

  useEffect(() => {
    if (location) {
      debouncedGeocodeLocation(location);
    }
  }, [location, debouncedGeocodeLocation]);

  useEffect(() => {
    if (position && mapRef.current) {
      const map = mapRef.current;
      map.flyTo(position, 15); // Adjust the zoom level as needed
    }
  }, [position]);

  const LocationMarker = () => {
    useMapEvents({
      click(e) {
        const lat = e.latlng.lat.toFixed(LAT_LON_PRECISION);
        const lon = e.latlng.lng.toFixed(LAT_LON_PRECISION);
        setPosition([parseFloat(lat), parseFloat(lon)]);
        setLocation(`${lat},${lon}`);
        getWeather({ variables: { input: { input: { location: `${lat},${lon}` } } } });
      },
    });

    return position === null ? null : <Marker position={position}></Marker>;
  };

  return (
    <PageContainer>
      <FormContainer>
        <Header>CARPE CAELUM</Header>
        <MapContainerStyled
          center={position || [37.334587, -122.008753]}
          zoom={13}
          ref={mapRef}
        >
          <TileLayer
            url="https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}.png?apikey=3151821c90f5417ba9baa0c4320be33e"
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
            <p>Temperature: {data.getWeather.temperature}°F</p>
            <p>Description: {data.getWeather.description}</p>
          </ResultContainer>
        )}
      </FormContainer>
    </PageContainer>
  );
};

export default LocationForm;
