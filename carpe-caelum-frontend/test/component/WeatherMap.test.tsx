import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import { describe, it, vi, expect, beforeEach } from 'vitest'
import WeatherMap from '../../src/components/WeatherMap'
import '@testing-library/jest-dom'

// Mocking the imports for react-leaflet
vi.mock('react-leaflet', () => {
    const actualModule = vi.importActual('react-leaflet')
    return {
        ...actualModule,
        MapContainer: ({ children, ...props }) => (
            <div data-testid="map-container" {...props}>
                {children}
            </div>
        ),
        TileLayer: ({ url }) => <div data-testid="tile-layer" data-url={url} />,
        Marker: ({ position }) => (
            <div data-testid="marker" data-position={position.join(',')} />
        ),
        useMapEvents: vi.fn().mockImplementation((handlers) => {
            setTimeout(() => {
                handlers.click({ latlng: { lat: 40, lng: -70 } })
            }, 0)
        }),
    }
})

// Mock Vite's import.meta.env
vi.mock('@vite/client', () => ({
    VITE_THUNDERFOREST_API_KEY: 'mock-api-key',
}))

describe('WeatherMap', () => {
    const setPosition = vi.fn()
    const getWeather = vi.fn().mockResolvedValue({ data: {} })
    const defaultProps = {
        position: [37.7749, -122.4194] as [number, number],
        setPosition,
        LAT_LON_PRECISION: 2,
        getWeather,
    }

    beforeEach(() => {
        vi.clearAllMocks()
    })

    it('renders without crashing', () => {
        render(<WeatherMap {...defaultProps} />)
        expect(screen.getByTestId('map-container')).toBeInTheDocument()
        expect(screen.getByTestId('tile-layer')).toBeInTheDocument()
    })

    it('displays an error when API key is not defined', () => {
        vi.stubEnv('VITE_THUNDERFOREST_API_KEY', '')
        render(<WeatherMap {...defaultProps} />)
        expect(
            screen.getByText('Error: API key for Thunderforest is not defined.')
        ).toBeInTheDocument()
        vi.unstubAllEnvs()
    })

    it('handles map click events and updates position', async () => {
        render(<WeatherMap {...defaultProps} />)

        await waitFor(() => {
            expect(setPosition).toHaveBeenCalledWith([40, -70])
            expect(getWeather).toHaveBeenCalledWith({
                variables: { latitude: 40, longitude: -70 },
            })
        })
    })
})
