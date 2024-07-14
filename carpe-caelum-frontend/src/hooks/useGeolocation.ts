import { useCallback } from 'react'
import { LAT_LON_PRECISION } from '../constants'

/**
 * Custom hook to handle geolocation functionality.
 *
 * @param setLocation - Function to update the location state as a string (latitude, longitude).
 * @param setPosition - Function to update the position state as an array of latitude and longitude.
 * @returns handleGeolocation - A function to get the current position using the Geolocation API.
 */
const useGeolocation = (
    setLocation: (location: string) => void,
    setPosition: (position: [number, number]) => void
) => {
    /**
     * Function to get the current position using the Geolocation API.
     * This function is memoized using useCallback to avoid unnecessary re-renders.
     */
    const handleGeolocation = useCallback(() => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    // Extract latitude and longitude from the position object and format them to a fixed precision
                    const lat =
                        position.coords.latitude.toFixed(LAT_LON_PRECISION)
                    const lon =
                        position.coords.longitude.toFixed(LAT_LON_PRECISION)

                    // Update the location and position states with the formatted latitude and longitude
                    setLocation(`${lat},${lon}`)
                    setPosition([parseFloat(lat), parseFloat(lon)])
                },
                (error) => {
                    console.error('Error fetching geolocation:', error)
                    alert('Unable to fetch your location.')
                }
            )
        } else {
            alert('Geolocation is not supported by this browser.')
        }
    }, [setLocation, setPosition])

    return handleGeolocation
}

export default useGeolocation
