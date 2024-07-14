import React, { useEffect, useRef } from 'react'
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet'
import styled from 'styled-components'
import { Map as LeafletMap, LeafletMouseEvent } from 'leaflet'

// Styled component for the MapContainer
const MapContainerStyled = styled(MapContainer)`
    height: 400px;
    width: 100%;
    margin-top: 16px;
`

// Define types for props and the response of getWeather
interface WeatherMapProps {
    position: [number, number] | null
    setPosition: (position: [number, number]) => void
    LAT_LON_PRECISION: number
    getWeather: (options?: {
        variables: { input: { input: { location: string } } }
    }) => Promise<{ data: unknown }>
}

interface LocationMarkerProps {
    LAT_LON_PRECISION: number
    setPosition: (position: [number, number]) => void
    getWeather: (options?: {
        variables: { input: { input: { location: string } } }
    }) => Promise<{ data: unknown }>
    position: [number, number] | null
}

// Functional component for the LocationMarker
const LocationMarker: React.FC<LocationMarkerProps> = ({
    LAT_LON_PRECISION,
    setPosition,
    getWeather,
    position,
}) => {
    useMapEvents({
        click(e: LeafletMouseEvent) {
            const lat = e.latlng.lat.toFixed(LAT_LON_PRECISION)
            const lon = e.latlng.lng.toFixed(LAT_LON_PRECISION)
            const newPosition: [number, number] = [
                parseFloat(lat),
                parseFloat(lon),
            ]
            setPosition(newPosition)
            getWeather({
                variables: { input: { input: { location: `${lat},${lon}` } } },
            })
        },
    })

    return position ? <Marker position={position} /> : null
}

// Functional component for the WeatherMap
const WeatherMap: React.FC<WeatherMapProps> = ({
    position,
    setPosition,
    LAT_LON_PRECISION,
    getWeather,
}) => {
    const mapRef = useRef<LeafletMap>(null)

    useEffect(() => {
        if (position && mapRef.current) {
            mapRef.current.flyTo(position, 15) // Adjusts the zoom level when flying to a location.
        }
    }, [position])

    // Fetch the API key from environment variables
    const apiKey = import.meta.env.VITE_THUNDERFOREST_API_KEY

    if (!apiKey) {
        return <div>Error: API key for Thunderforest is not defined.</div>
    }

    return (
        <MapContainerStyled
            center={position || [37.334587, -122.008753]}
            zoom={13}
            ref={mapRef}
        >
            <TileLayer
                url={`https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}.png?apikey=${apiKey}`}
            />
            <LocationMarker
                LAT_LON_PRECISION={LAT_LON_PRECISION}
                setPosition={setPosition}
                getWeather={getWeather}
                position={position}
            />
        </MapContainerStyled>
    )
}

export default WeatherMap
