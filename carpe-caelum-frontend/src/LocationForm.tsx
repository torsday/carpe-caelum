import React, { useState } from 'react';
import { gql, useMutation } from '@apollo/client';

const GET_WEATHER = gql`
  mutation GetWeather($input: GetWeatherInput!) {
    getWeather(input: $input) {
      temperature
      description
    }
  }
`;

const LocationForm: React.FC = () => {
  const [location, setLocation] = useState('');
  const [getWeather, { data, loading, error }] = useMutation(GET_WEATHER);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    getWeather({ variables: { input: { input: { location } } } });
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          placeholder="Enter location"
        />
        <button type="submit">Get Weather</button>
      </form>
      {loading && <p>Loading...</p>}
      {error && <p>Error: {error.message}</p>}
      {data && (
        <div>
          <p>Temperature: {data.getWeather.temperature}°C</p>
          <p>Description: {data.getWeather.description}</p>
        </div>
      )}
    </div>
  );
};

export default LocationForm;
