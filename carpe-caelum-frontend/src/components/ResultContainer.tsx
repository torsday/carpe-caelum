import React from 'react'
import styled from 'styled-components'
import { WeatherData } from '../interfaces/weatherInterfaces'

const ResultContainerStyled = styled.div`
    margin-top: 16px;
`

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

interface ResultContainerProps {
    weatherData: WeatherData | null
}

const ResultContainer: React.FC<ResultContainerProps> = ({ weatherData }) => {
    return (
        <ResultContainerStyled>
            <p>5 Hour Forecast (Low &lt; Present &lt; High) in °F</p>
            <TemperatureRange>
                <span>{weatherData?.weather.fiveHrTemperatureLow}°F</span>
                &lt;
                <span>{weatherData?.weather.temperature}°F</span>
                &lt;
                <span>{weatherData?.weather.fiveHrTemperatureHigh}°F</span>
            </TemperatureRange>
            {weatherData?.weather.description && (
                <p>{weatherData.weather.description}</p>
            )}
            {weatherData?.weather.errorMessage && (
                <p>Error: {weatherData.weather.errorMessage}</p>
            )}
        </ResultContainerStyled>
    )
}

export default ResultContainer
