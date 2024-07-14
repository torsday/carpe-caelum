import React from 'react'
import styled from 'styled-components'
import { WeatherData } from '../interfaces/weatherInterfaces'

// Styled component for the ResultContainer
const ResultContainerStyled = styled.div`
    margin-top: 16px;
`

// Styled component for displaying temperature range
const TemperatureRange = styled.p`
    font-size: 1.2rem;
    font-weight: bold;
    color: #b58900;
    display: flex;
    justify-content: center;
    align-items: center;

    span {
        margin: 0 8px;
        color: #268bd2;
    }
`

// Interface for the props of the ResultContainer component
interface ResultContainerProps {
    weatherData: WeatherData | null
}

// Functional component to display weather results
const ResultContainer: React.FC<ResultContainerProps> = ({ weatherData }) => {
    // Return null if no weather data is available
    if (!weatherData || !weatherData.weather) {
        return null
    }

    // Deconstruct the weather data
    const {
        temperature,
        fiveHrTemperatureLow,
        fiveHrTemperatureHigh,
        description,
        errorMessage,
    } = weatherData.weather

    return (
        <ResultContainerStyled>
            <p>5 Hour Forecast (Low &lt; Present &lt; High) in °F</p>
            <TemperatureRange>
                <span>{fiveHrTemperatureLow}°F</span>
                &lt;
                <span>{temperature}°F</span>
                &lt;
                <span>{fiveHrTemperatureHigh}°F</span>
            </TemperatureRange>
            {description && <p>{description}</p>}
            {errorMessage && <p>Error: {errorMessage}</p>}
        </ResultContainerStyled>
    )
}

export default ResultContainer
