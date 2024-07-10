import React, { useState } from 'react';
import { gql, useMutation } from '@apollo/client';
import styled from 'styled-components';

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
`;

const InputContainer = styled.div`
  display: flex;
  align-items: center;
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
  background-color: ${props => props.type === 'submit' ? '#28A745' : '#007BFF'};
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

const LocationForm: React.FC = () => {
  const [location, setLocation] = useState('');
  const [getWeather, { data, loading, error }] = useMutation(GET_WEATHER);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    getWeather({ variables: { input: { input: {location} } } });
  };

  const handleGeolocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lon = position.coords.longitude;
          setLocation(`${lat},${lon}`);
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

  return (
    <FormContainer>
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
