import React from 'react'
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom'
import ResultContainer from '../../src/components/ResultContainer'
import { WeatherData } from '../../src/interfaces/weatherInterfaces'

describe('ResultContainer', () => {
    const mockWeatherData: WeatherData = {
        weather: {
            temperature: 70,
            fiveHrTemperatureLow: 65,
            fiveHrTemperatureHigh: 75,
            description: 'Sunny',
            errorMessage: null,
        },
    }

    const mockErrorData: WeatherData = {
        weather: {
            temperature: 70,
            fiveHrTemperatureLow: 65,
            fiveHrTemperatureHigh: 75,
            description: 'Sunny',
            errorMessage: 'Failed to fetch data',
        },
    }

    it('renders the weather data correctly', () => {
        render(<ResultContainer weatherData={mockWeatherData} />)

        expect(
            screen.getByText('5 Hour Forecast (Low < Present < High) in °F')
        ).toBeInTheDocument()
        expect(screen.getByText('65°F')).toBeInTheDocument()
        expect(screen.getByText('70°F')).toBeInTheDocument()
        expect(screen.getByText('75°F')).toBeInTheDocument()
        expect(screen.getByText('Sunny')).toBeInTheDocument()
    })

    it('renders null when there is no weather data', () => {
        const { container } = render(<ResultContainer weatherData={null} />)
        expect(container.firstChild).toBeNull()
    })

    it('displays an error message when errorMessage is present', () => {
        render(<ResultContainer weatherData={mockErrorData} />)

        expect(
            screen.getByText('Error: Failed to fetch data')
        ).toBeInTheDocument()
    })
})
