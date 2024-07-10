import React, { useEffect, useRef } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import styled from 'styled-components';
import { Map as LeafletMap } from 'leaflet';

const MapContainerStyled = styled(MapContainer)`
  height: 400px;
  width: 100%;
  margin-top: 16px;
`;

interface WeatherMapProps {
  position: [number, number] | null;
  setPosition: (position: [number, number]) => void;
  LAT_LON_PRECISION: number;
  getWeather: (options?: any) => Promise<any>;
}

const WeatherMap: React.FC<WeatherMapProps> = ({ position, setPosition, LAT_LON_PRECISION, getWeather }) => {
  const mapRef = useRef<LeafletMap>(null);

  const LocationMarker = () => {
    useMapEvents({
      click(e) {
        const lat = e.latlng.lat.toFixed(LAT_LON_PRECISION);
        const lon = e.latlng.lng.toFixed(LAT_LON_PRECISION);
        setPosition([parseFloat(lat), parseFloat(lon)]);
        getWeather({ variables: { input: { input: { location: `${lat},${lon}` } } } });
      },
    });

    return position === null ? null : <Marker position={position}></Marker>;
  };

  useEffect(() => {
    if (position && mapRef.current) {
      const map = mapRef.current;
      map.flyTo(position, 15); // Adjusts the zoom level when flying to a location.
    }
  }, [position]);

  return (
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
  );
};

export default WeatherMap;
